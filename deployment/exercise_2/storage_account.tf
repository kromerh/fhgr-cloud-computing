/*
Hilfestellung Exercise 2: Storage Account
Diese Datei ist auskommentiert, damit Terraform sie ignoriert. Kopiert den Block nach main.tf und füllt die Lücken.

resource "azurerm_storage_account" "stac_primary" {
  name                     = "name" # global eindeutig: stac<projekt><initialen><zahl>, z. B. stacprimaryhkr100
  resource_group_name      = res.name.???
  location                 = "..."
  account_tier             = "Standard"
  account_replication_type = "LRS"
  tags                     = ...
}
*/
