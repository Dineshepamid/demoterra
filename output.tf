#output for ResourceGroup name
output "azurerm_resource_group_name" {
description   = "RG Name"
value         = azurerm_resource_group.Rg2.name
}
#output for Resources -VM
output "azurerm_virtual-machine_name" {
description   = "this is the vm name for the virtual machine"
value         = azurerm_virtual_machine.main.name
}