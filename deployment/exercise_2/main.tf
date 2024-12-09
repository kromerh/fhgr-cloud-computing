provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg_primary" {
  name     = "rg-vorlesung-4-ex2"
  location = var.location
}

resource "azurerm_storage_account" "stac_primary" {
  name                     = "stacvorlesung4ex2"
  resource_group_name      = azurerm_resource_group.rg_primary.name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

