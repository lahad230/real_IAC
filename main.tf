terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=2.46.0"
    }
  }
}

#######Rg,Vnets, subnets and nsgs#######

module "projBase" {
  source = "./modules/projBase"
  resourceGroupName = var.resourceGroupName
  location          = var.location
  vNet              = var.vNet 
  publicSubnet      = var.publicSubnet
  # privateSubnet     = var.privateSubnet  
}

#public subnet's nsg:
resource "azurerm_network_security_group" "web" {
  name                = var.publicNsg
  location            = module.projBase.rg_location
  resource_group_name = module.projBase.rg_name

  security_rule { 
    name                       = "ports"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_ranges    = var.webNsgPorts
    source_address_prefixes    = [ 
      "140.82.112.0/20", 
      "192.30.252.0/22", 
      "83.130.78.36"
    ]
    destination_address_prefix = "*"
  }
}

#public subnet nsg association:
resource "azurerm_subnet_network_security_group_association" "publicNsg" {
  subnet_id                 = module.projBase.public_subnet_id
  network_security_group_id = azurerm_network_security_group.web.id
}

##########Public ips##########

#public load balancer ip:
resource "azurerm_public_ip" "ip" {
  name                = "ip"
  resource_group_name = module.projBase.rg_name
  location            = module.projBase.rg_location
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_public_ip" "jenkinsip" {
  name                = "jenkinsip"
  resource_group_name = module.projBase.rg_name
  location            = module.projBase.rg_location
  allocation_method   = "Static"
  sku                 = "Standard"
}

######jenkins machine######

resource "azurerm_network_interface" "jenNic" {
  name                = "jenkinsNic"
  location            = module.projBase.rg_location
  resource_group_name = module.projBase.rg_name

  ip_configuration {
    name                          = "jenNicConf"
    subnet_id                     = module.projBase.public_subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.jenkinsip.id
  }
}

resource "azurerm_linux_virtual_machine" "Vm" {
  name                = "jenkins"
  resource_group_name = module.projBase.rg_name
  location            = module.projBase.rg_location
  size                = var.vmSize
  admin_username      = var.username
  admin_password      = var.password

  disable_password_authentication = false
  
  network_interface_ids = [
    azurerm_network_interface.jenNic.id
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}

######VMs and NICs######
#VMs and nics hosting web application:
module "web" {
  source            = "./modules/linuxVm"
  count             = var.numOfPublicVms
  vm_name           = "web${count.index}"
  rg_name           = module.projBase.rg_name
  rg_location       = module.projBase.rg_location
  vm_size           = var.vmSize
  vm_username       = var.username
  vm_password       = var.password
  nic_name          = "webNic${count.index}"
  nic_conf_name     = "webConf${count.index}"
  subnet_id         = module.projBase.public_subnet_id
  okta_url          = var.okta_url
  okta_id           = var.okta_id
  okta_secret       = var.okta_secret
  postgres_user     = var.postgres_user
  postgres_password = var.postgresPassword

  fqdn          = azurerm_postgresql_server.postgres.fqdn
  depends_on = [
    azurerm_postgresql_server.postgres
  ]
}

###########Load balancers, probes, pools and rules############

#public load balancer:
resource "azurerm_lb" "publicLb" {
  name                = var.publicLb.name
  location            = module.projBase.rg_location
  resource_group_name = module.projBase.rg_name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = var.publicLb.frontIpName
    public_ip_address_id = azurerm_public_ip.ip.id
  }
}

#public load balancer backend pool:
resource "azurerm_lb_backend_address_pool" "publicLbPool" {
  loadbalancer_id = azurerm_lb.publicLb.id
  name            = "frontEndAddressPool"
}

#public load balancer pool associations:
resource "azurerm_network_interface_backend_address_pool_association" "webPool" {
  count                   = var.numOfPublicVms
  network_interface_id    = module.web[count.index].nic_id
  ip_configuration_name   = module.web[count.index].nic_if_conf_name
  backend_address_pool_id = azurerm_lb_backend_address_pool.publicLbPool.id
}

#public load balancer outbound rule:
resource "azurerm_lb_outbound_rule" "publicLbOutbound" {
  resource_group_name     = module.projBase.rg_name
  loadbalancer_id         = azurerm_lb.publicLb.id
  name                    = "OutboundRule"
  protocol                = "Tcp"
  backend_address_pool_id = azurerm_lb_backend_address_pool.publicLbPool.id

  frontend_ip_configuration {
    name = azurerm_lb.publicLb.frontend_ip_configuration[0].name
  }
}

#public load balancer probe(health checks):
resource "azurerm_lb_probe" "publicLbProbe" {
  resource_group_name = module.projBase.rg_name
  loadbalancer_id     = azurerm_lb.publicLb.id
  name                = "8080-running-probe"
  port                = var.frontPort
}

#public load balancer load balancing rule:
resource "azurerm_lb_rule" "publicLbRule" {
  resource_group_name            = module.projBase.rg_name
  loadbalancer_id                = azurerm_lb.publicLb.id
  name                           = "PublicLBRule"
  protocol                       = "Tcp"
  frontend_port                  = var.frontPort
  backend_port                   = var.frontPort
  disable_outbound_snat          = true
  frontend_ip_configuration_name = azurerm_lb.publicLb.frontend_ip_configuration[0].name
  backend_address_pool_id        = azurerm_lb_backend_address_pool.publicLbPool.id
  probe_id                       = azurerm_lb_probe.publicLbProbe.id
}

resource "azurerm_postgresql_server" "postgres" {
  name                         = "weightdb"
  location                     = module.projBase.rg_location
  resource_group_name          = module.projBase.rg_name
  administrator_login          = var.postgresUser
  administrator_login_password = var.postgresPassword

  sku_name                     = "GP_Gen5_4"
  version                      = "11"
  ssl_enforcement_enabled      = false
}

resource "azurerm_postgresql_firewall_rule" "postgresFire" {
  name                = "postgresFire"
  resource_group_name = module.projBase.rg_name
  server_name         = azurerm_postgresql_server.postgres.name
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "0.0.0.0"
}