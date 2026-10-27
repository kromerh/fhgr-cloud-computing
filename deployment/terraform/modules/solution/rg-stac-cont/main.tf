resource "azurerm_resource_group" "rg" {
  name     = "rg-${var.name}-${var.initialen}"
  location = var.location
  tags     = var.common_tags
}

resource "azurerm_storage_account" "stac" {
  name                     = "stac${var.name}${var.initialen}"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = var.account_tier
  account_replication_type = var.account_replication_type
  tags                     = var.common_tags
}

resource "azurerm_storage_container" "container" {
  name                  = "${var.name}-container"
  storage_account_id    = azurerm_storage_account.stac.id
  container_access_type = var.container_access_type
}
