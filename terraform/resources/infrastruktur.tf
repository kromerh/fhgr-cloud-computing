provider "azurerm" {  
  features {}  
}  
  
resource "azurerm_resource_group" "example" {  
  name     = "example-resources"  
  location = "..."
  ...
}  
  
resource "azurerm_storage_account" "example" {
  name                     = "examplestoracc"
  ...
}  
  
resource "azurerm_storage_container" "example" {
  name                  = "example-container"
  ...
}  
  
resource "azurerm_storage_queue" "example" {
  name                 = "example-queue"
  ...
}  

resource "azurerm_virtual_network" "vnet_primary" {  
  name                = "vnet-primary"
  resource_group_name = ...
  location            = ...
  address_space       = ["10.0.0.0/16"]  
}  
  
resource "azurerm_subnet" "subnet_primary" {  
  name                 = "subnet-primary"  
  resource_group_name  = ...
  virtual_network_name = ...
  address_prefixes     = ["10.0.2.0/24"]  
}  
  
resource "azurerm_network_interface" "nic_primary" {  
  name                = "nic-primary"
  resource_group_name = ...
  location            = ...
  
  ip_configuration {  
    name                          = "internal"  
    subnet_id                     = ...
    private_ip_address_allocation = "Dynamic"  
  }  
}  
  
resource "azurerm_linux_virtual_machine" "vm_primary" {  
  name                = "vm-primary"
  resource_group_name = ...
  location            = ...
  size                = "Standard_B1ls"
network_interface_ids = [
    azurerm_network_interface.nic_primary.id,
  ]
  admin_username      = "adminuser"  
  admin_password      = "P@ssw0rd123!65gashdfasdfasdfasd412356th"  
  disable_password_authentication = false  
  
  os_disk {  
    caching              = "ReadWrite"  
    storage_account_type = "Standard_LRS"  
  }  
  
  source_image_reference {  
    publisher = "Canonical"  
    offer     = "UbuntuServer"  
    sku       = "16.04-LTS"  
    version   = "latest"  
  }  
}