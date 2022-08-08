# Resource - Resource group creation
resource "azurerm_resource_group" "Rg2" {
name      = var.azurerm_resource_group #calling to variables file
location  = var.azurerm_resource_group_location #calling to variables file
}

# Resource - Creation of Vnet
resource "azurerm_virtual_network" "main" {
  name                = "${var.prefix}-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.Rg2.location
  resource_group_name = azurerm_resource_group.Rg2.name
}
# Resource - Subnet creation
resource "azurerm_subnet" "internal" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.Rg2.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.2.0/24"]
}
#Resource - Interface creation which required for VM to communicate
resource "azurerm_network_interface" "main" {
  name                = "${var.prefix}-nic"
  location            = azurerm_resource_group.Rg2.location
  resource_group_name = azurerm_resource_group.Rg2.name

  ip_configuration {
    name                          = "testconfiguration1"
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
  }
}
# Resource - creation of VM
resource "azurerm_virtual_machine" "main" {
  name                  = "${var.prefix}-vm"
  location              = azurerm_resource_group.Rg2.location
  resource_group_name   = azurerm_resource_group.Rg2.name
  network_interface_ids = [azurerm_network_interface.main.id]
  vm_size               = "Standard_DS1_v2"

  # Uncomment this line to delete the OS disk automatically when deleting the VM
  # delete_os_disk_on_termination = true

  # Uncomment this line to delete the data disks automatically when deleting the VM
  # delete_data_disks_on_termination = true

  storage_image_reference { #storage Specification part of VM creation 
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
  storage_os_disk { #Disk Specification part of VM creation 
    name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile { #OS Specification part of VM creation 
    computer_name  = "hostname"
    admin_username = "testadmin"
    admin_password = "Password1234!"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  tags = {
    environment = "staging"
  }
}

# Resource - Network security Group creation
resource "azurerm_network_security_group" "gateway" {
name                  = "${var.prefix}-var.network_gateway"  
resource_group_name   = azurerm_resource_group.Rg2.name
location              = azurerm_resource_group.Rg2.location
}
##### Resource - Associating the Subnet & NSG   
resource "azurerm_subnet_network_security_group_association" "nsgsubnetassociation" {
  depends_on                = [azurerm_network_security_rule.NSG_rule_inbound]#Every NSG Rule association will disassociate NSG from subnet and associate it ,so we associate it only after NSG is Completely Created -Azure Provide Bug https://github.com/terraform-providers/terraform=provider-azurerm/issues/354
  subnet_id                 = azurerm_subnet.internal.id
  network_security_group_id = azurerm_network_security_group.gateway.id
}

# Resource - creation rule for NSG
resource "azurerm_network_security_rule" "NSG_rule_inbound"{
  name                        = "Rule-Port-3389"
  priority                    =  100
  direction                   = "Inbound" 
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "3389"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.Rg2.name
  network_security_group_name = azurerm_network_security_group.gateway.name 
}
resource "azurerm_public_ip" "publi_ip_for_use" {
  name                = "acceptanceTestPublicIp1"
  resource_group_name = azurerm_resource_group.Rg2.name
  location            = azurerm_resource_group.Rg2.location
  allocation_method   = "Static"

  tags = {
    environment = "Production"
  }
}