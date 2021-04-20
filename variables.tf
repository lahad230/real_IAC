variable "vmSize" {
  description = "size of both web vms and db vms."
  type        = string
  default     = "Standard_B2s"
}

variable "location" {
  description = "location of all the resources. eg-> Germany West Central"
  type        = string
}

variable "username" {
  description = "all vms username. eg-> myUsername"
  type        = string
}

variable "password" {
  description = "all vms passwords. eg->sTRongPasswoRd"
  type        = string
}

variable "resourceGroupName" {
  description = "main resource group name."
  type        = string
}

variable "vNet" {
  description = "name and cidr for Vnet. eg-> name = 'Vnet' cidr = '10.0.0.0/16'" 
  type        = map
}

variable "publicSubnet" {
  description = "public subnet cidr and name. eg-> name ='mysubenet' cidr = '10.0.1.0/28'"
  type        = map
}


variable "publicNsg" {
  description = "name of the nsg associated with public subnet"
  type = string
}

variable "publicLb" {
  description = "public load balancer details (name and front ip name). eg-> name = 'publicLb' frontIpName = 'lbForntIp'"
  type        = map
}

variable "numOfPublicVms" {
  description = "number of vms on the public subnet"
  type        = number
}

variable "webNsgPorts" {
  description = "list of ports open on the public subnet's nsg"
  type = list
}

variable "frontPort" {
  description = "main port for public parts"
  type = number
}

variable "postgresUser" {
  description = "postgres username"
  type        = string
}

variable "postgresPassword" {
  description = "password for postgresql"
  type        = string
}