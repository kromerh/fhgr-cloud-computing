resource "azurerm_storage_account" "stac_primary" {  
  name                     = "stacprimaryheiko1581"  
  resource_group_name      = azurerm_resource_group.rg_primary.name  
  location                 = "..."
  account_tier             = "Standard"  
  account_replication_type = "LRS"  
}  