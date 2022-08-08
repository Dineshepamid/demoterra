#creating variable for Resource Group  

variable "azurerm_resource_group" {
description = "this is variable file for resource group"
type = string 
default = "raja"
}
variable "azurerm_resource_group_location" {
description = "this is variable file for location of the resource group"
type = string 
default = "west us"
}
variable "azurerm_virtual_machine" {
description = "this the VM"
type = string  
default = "vmforever"
}
variable "prefix" {
  default = "tfvmex"
}
variable "network_gateway" {
description = "this is reference of network gateway name"
type = string
default = "natmama"
}