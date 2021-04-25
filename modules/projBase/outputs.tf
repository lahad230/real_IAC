output "rg_name" {
    description = "id of the resourse group"
    value       = azurerm_resource_group.rg.name
}

output "rg_location" {
    description = "location of the resourse group"
    value       = azurerm_resource_group.rg.location
}

output "vnet_name" {
    description = "name of the vnet"
    value       = azurerm_virtual_network.vnet.name
}

output "public_subnet_id" {
    description = "id of the public subnet"
    value       = azurerm_subnet.publicSubnet.id
}

output "private_subnet_id" {
    description = "id of the private subnet"
    value       = azurerm_subnet.privateSubnet.id
}
