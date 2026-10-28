/*
Hilfestellung Exercise 4: dreimal Resource Group, Storage Account und Storage Container
Diese Datei ist auskommentiert, damit Terraform sie ignoriert. Kopiert die Blöcke nach main.tf und füllt die Lücken.

resource "azurerm_resource_group" "rg_primary" {
  name     = ...
  location = ...
}

resource "azurerm_storage_account" "stac_primary" {
  name                     = ...
  resource_group_name      = azurerm_resource_group.rg_primary.name
  location                 = ...
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "container_primary" {
  name                  = ...
  storage_account_id    = azurerm_storage_account.stac_primary.id
  container_access_type = "private"
}

resource "azurerm_resource_group" "rg_secondary" {

}

resource "azurerm_storage_account" "stac_secondary" {

}

resource "azurerm_storage_container" "container_secondary" {

}

resource "azurerm_resource_group" "rg_tertiary" {

}

resource "azurerm_storage_account" "stac_tertiary" {

}

resource "azurerm_storage_container" "container_tertiary" {

}
*/
