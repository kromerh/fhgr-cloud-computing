# Lösungs-Snippet: gehört in main.tf der Exercise (terraform- und provider-Block stehen dort, Variablen in variables.tf).

resource "azurerm_resource_group" "rg_primary" {
  name     = "rg-terraform-practice-primary-${var.initialen}"
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

resource "azurerm_resource_group" "rg_secondary" {
  name     = "rg-terraform-practice-secondary-${var.initialen}"
  location = var.location
  tags     = var.common_tags
}

resource "azurerm_storage_account" "stac_secondary" {
  name                     = "stacsecondary${var.initialen}"
  resource_group_name      = azurerm_resource_group.rg_secondary.name
  location                 = azurerm_resource_group.rg_secondary.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  tags                     = var.common_tags
}

resource "azurerm_storage_container" "container_secondary" {
  name                  = "secondary-container"
  storage_account_id    = azurerm_storage_account.stac_secondary.id
  container_access_type = "private"
}

resource "azurerm_resource_group" "rg_tertiary" {
  name     = "rg-terraform-practice-tertiary-${var.initialen}"
  location = var.location
  tags     = var.common_tags
}

resource "azurerm_storage_account" "stac_tertiary" {
  name                     = "stactertiary${var.initialen}"
  resource_group_name      = azurerm_resource_group.rg_tertiary.name
  location                 = azurerm_resource_group.rg_tertiary.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  tags                     = var.common_tags
}

resource "azurerm_storage_container" "container_tertiary" {
  name                  = "tertiary-container"
  storage_account_id    = azurerm_storage_account.stac_tertiary.id
  container_access_type = "private"
}
