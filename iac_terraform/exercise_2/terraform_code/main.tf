provider "azurerm" {  
  features {}  
}  

resource "azurerm_resource_group" "rg_primary" {  
  name     = "rg-terraform-practice-primary"
  location = "switzerlandnorth"
}  

resource "azurerm_storage_account" "stac_primary" {  
  name                     = "stacprimaryheiko1581"  
  resource_group_name      = azurerm_resource_group.rg_primary.name  
  location                 = azurerm_resource_group.rg_primary.location
  account_tier             = "Standard"  
  account_replication_type = "LRS"  
}  

resource "azurerm_storage_container" "container_primary" {  
  name                  = "primary-container"
  storage_account_name  = azurerm_storage_account.stac_primary.name
  container_access_type = "private"  
}  

resource "azurerm_resource_group" "rg_secondary" {  
  name     = "rg-terraform-practice-secondary"
  location = "switzerlandnorth"
}  

resource "azurerm_storage_account" "stac_secondary" {  
  name                     = "stacsecondaryheiko1581"  
  resource_group_name      = azurerm_resource_group.rg_secondary.name  
  location                 = azurerm_resource_group.rg_secondary.location
  account_tier             = "Standard"  
  account_replication_type = "LRS"  
}  

resource "azurerm_storage_container" "container_secondary" {  
  name                  = "secondary-container"
  storage_account_name  = azurerm_storage_account.stac_secondary.name
  container_access_type = "private"  
}  

resource "azurerm_resource_group" "rg_tertiary" {  
  name     = "rg-terraform-practice-tertiary"
  location = "switzerlandnorth"
}  
  
resource "azurerm_storage_account" "stac_tertiary" {  
  name                     = "stactertiaryheiko1581"  
  resource_group_name      = azurerm_resource_group.rg_tertiary.name  
  location                 = azurerm_resource_group.rg_tertiary.location
  account_tier             = "Standard"  
  account_replication_type = "LRS"  
}  

resource "azurerm_storage_container" "container_tertiary" {  
  name                  = "tertiary-container"
  storage_account_name  = azurerm_storage_account.stac_tertiary.name
  container_access_type = "private"  
}  
