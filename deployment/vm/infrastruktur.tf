provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg_primary" {
  name     = "rg-terraform-practice-4"
  location = "westeurope"
}

resource "azurerm_storage_account" "stac_primary" {
  name                     = "stacprihkr123"
  resource_group_name      = azurerm_resource_group.rg_primary.name
  location                 = azurerm_resource_group.rg_primary.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "container_primary" {
  name                  = "primary-container"
  storage_account_name  = azurerm_storage_account.stac_primary.name
  container_access_type = "private"
}

resource "azurerm_storage_queue" "queue_primary" {
  name                 = "primary-queue"
  storage_account_name = azurerm_storage_account.stac_primary.name
}

resource "azurerm_virtual_network" "vnet_primary" {
  name                = "vnet-primary-3"
  resource_group_name = azurerm_resource_group.rg_primary.name
  location            = azurerm_resource_group.rg_primary.location
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "subnet_primary" {
  name                 = "subnet-primary"
  resource_group_name = azurerm_resource_group.rg_primary.name
  virtual_network_name = azurerm_virtual_network.vnet_primary.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "nic_primary" {
  name                = "nic-primary-3"
  resource_group_name = azurerm_resource_group.rg_primary.name
  location            = azurerm_resource_group.rg_primary.location

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet_primary.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "vm_primary" {
  name                = "vm-primary"
  resource_group_name = azurerm_resource_group.rg_primary.name
  location            = "westeurope"
  size                = "Standard_DS1_v2"
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
