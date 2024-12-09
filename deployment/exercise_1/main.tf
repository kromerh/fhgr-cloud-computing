provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg_primary" {
  name     = var.rg_name
  location = var.location
  tags     = { "hallo" = "welt" }
}
