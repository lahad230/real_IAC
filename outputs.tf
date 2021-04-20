output "vmPassword" {
    description = "admin password for the vms"
    value       = module.web[0].vmPassword
}