provider "azurerm" {  
  features {}  
}  
  
resource "azurerm_resource_group" "rg_primary" {  
  name     = "rg-terraform-practice"
  location = "switzerlandnorth"
}  
