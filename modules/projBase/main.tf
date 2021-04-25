terraform {
  required_version = ">=0.14.10"
}

resource "azurerm_resource_group" "rg" {
  name     = var.resourceGroupName
  location = var.location
}

#######Vnets, subnets and nsgs#######

#main vnet:
resource "azurerm_virtual_network" "vnet" {
  name                = var.vNet.name
  address_space       = [var.vNet.cidr]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

#public subnet:
resource "azurerm_subnet" "publicSubnet" {
  name                 = var.publicSubnet.name
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.publicSubnet.cidr]
  service_endpoints    = ["Microsoft.Sql"]
}

#private subnet:
resource "azurerm_subnet" "privateSubnet" {
  name                 = var.privateSubnet.name
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.privateSubnet.cidr]
}