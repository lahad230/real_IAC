variable "resourceGroupName" {
  type = string
  description = "name of the resource group"
}

variable "location" {
  type = string
  description = "name of the resource group location"
}

variable "vNet" {
  description = "name and cidr for Vnet. eg-> name = 'Vnet' cidr = '10.0.0.0/16'" 
  type        = map
}

variable "publicSubnet" {
  description = "public subnet cidr, name and associated nsg name. eg-> name ='mysubenet' cidr = '10.0.1.0/28' nsgName = 'nsgForsubnet'"
  type        = map
}

variable "privateSubnet" {
  description = "private subnet cidr, name and associated nsg name. eg-> name ='mysubenet' cidr = '10.0.1.0/28' nsgName = 'nsgForsubnet'"
  type        = map
}


