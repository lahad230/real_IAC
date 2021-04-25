variable "vm_name" {
  type       = string
  description = "name of the vm instance"
}

variable "rg_name" {
  type        = string
  description = "the name of the resource group hosting this vm"
}

variable "rg_location" {
  type        = string
  description = "the location of the resource group hosting this vm"
}

variable "vm_size" {
  type        = string
  default     = "Standard_B2s"
  description = "size of the vm"
}

variable "vm_username" {
  type        = string
  description = "admin username for vm"
}

variable "vm_password" {
  type        = string
  description = "admin password for the vm"
}

variable "nic_name" {
  type        = string
  description = "name of the nic"
}

variable "nic_conf_name" {
  type        = string
  description = "nic's ip configuration name"
}

variable "subnet_id" {
  type        = string
  description = "id of the subnet associated with the nic"
}

variable "postgres_password" {
  type        = string
  description = "postgres password"
}

variable "postgres_user" {
  type        = string
  description = "postgres user"
}