# Lösungs-Snippet: gehört in main.tf der Exercise (terraform- und provider-Block stehen dort, Variablen in variables.tf).

resource "azurerm_resource_group" "rg_primary" {
  name     = "rg-terraform-practice-${var.initialen}"
  location = var.location
  tags     = var.common_tags
}

resource "azurerm_storage_account" "stac_primary" {
  name                     = "stacprimary${var.initialen}"
  resource_group_name      = azurerm_resource_group.rg_primary.name
  location                 = azurerm_resource_group.rg_primary.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  tags                     = var.common_tags
}

resource "azurerm_storage_container" "container_primary" {
  name                  = "primary-container"
  storage_account_id    = azurerm_storage_account.stac_primary.id
  container_access_type = "private"
}

resource "azurerm_storage_queue" "queue_primary" {
  name               = "primary-queue"
  storage_account_id = azurerm_storage_account.stac_primary.id
}

resource "azurerm_virtual_network" "vnet_primary" {
  name                = "vnet-primary"
  resource_group_name = azurerm_resource_group.rg_primary.name
  location            = azurerm_resource_group.rg_primary.location
  address_space       = ["10.0.0.0/16"]
  tags                = var.common_tags
}

resource "azurerm_subnet" "subnet_primary" {
  name                 = "subnet-primary"
  resource_group_name  = azurerm_resource_group.rg_primary.name
  virtual_network_name = azurerm_virtual_network.vnet_primary.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "nic_primary" {
  name                = "nic-primary"
  resource_group_name = azurerm_resource_group.rg_primary.name
  location            = azurerm_resource_group.rg_primary.location
  tags                = var.common_tags

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet_primary.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "vm_primary" {
  name                = "vm-primary"
  resource_group_name = azurerm_resource_group.rg_primary.name
  location            = azurerm_resource_group.rg_primary.location
  size                = "Standard_B2ats_v2"
  network_interface_ids = [
    azurerm_network_interface.nic_primary.id,
  ]
  admin_username                  = "adminuser"
  disable_password_authentication = true
  tags                            = var.common_tags

  admin_ssh_key {
    username   = "adminuser"
    public_key = file(var.ssh_public_key_path)
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
