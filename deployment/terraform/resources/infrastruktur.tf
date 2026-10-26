/*
Hilfestellung Exercise 3: Pointers für main.tf und variables.tf
Diese Datei ist auskommentiert, damit Terraform sie ignoriert. Die Resource Group steht schon in main.tf.
Kopiert die Blöcke nach main.tf und ersetzt jedes "..." (Tipp: typ.name.attribut).

resource "azurerm_storage_account" "stac_primary" {
  name                     = "..." # global eindeutig: stac<projekt><initialen><zahl>
  ...
}

resource "azurerm_storage_container" "container_primary" {
  name               = "primary-container"
  storage_account_id = ...
  ...
}

resource "azurerm_storage_queue" "queue_primary" {
  name               = "primary-queue"
  storage_account_id = ...
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
  size                = "Standard_B2ats_v2"
  network_interface_ids = [
    azurerm_network_interface.nic_primary.id,
  ]
  admin_username                  = "adminuser"
  disable_password_authentication = true

  admin_ssh_key {
    username   = "adminuser"
    public_key = file(var.ssh_public_key_path) # Variable ssh_public_key_path in variables.tf anlegen, default "~/.ssh/id_rsa.pub"
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "server"
    version   = "latest"
  }
}
*/
