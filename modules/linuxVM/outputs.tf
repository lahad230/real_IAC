output "vmPassword" {
    description = "admin password for the vms"
    value       = azurerm_linux_virtual_machine.Vm.admin_password
}

output "nic_id" {
    description = "id of the nic"
    value       = azurerm_network_interface.nic.id
}

output "nic_if_conf_name" {
    description = "name of the nic's ip configuration name"
    value       = azurerm_network_interface.nic.ip_configuration[0].name
}
