resource "azurerm_resource_group" "rg" {  
  name     = "${var.name}-rg"  
  location = var.location  
}  

resource "azurerm_storage_account" "stac" {  
  name                     = "${var.name}stacheiko1581"  
  resource_group_name      = azurerm_resource_group.rg.name  
  location                 = azurerm_resource_group.rg.location  
  account_tier             = var.account_tier  
  account_replication_type = var.account_replication_type  
}  

resource "azurerm_storage_container" "container" {  
  name                  = "${var.name}-container"  
  storage_account_name  = azurerm_storage_account.stac.name  
  container_access_type = var.container_access_type  
}  
