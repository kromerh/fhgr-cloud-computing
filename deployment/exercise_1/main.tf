provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg_primary" {
  name     = "rg-terraform-practice"
  location = "switzerlandnorth"
}

az ad sp create-for-rbac --name  --role="Contributor" --scopes="/subscriptions/6795c425-c0c3-438c-b25f-6757acc7f034"

# Bash script
az ad sp create-for-rbac --name "sp-hkr" --role reader --scopes /subscriptions/6795c425-c0c3-438c-b25f-6757acc7f034/resourceGroups/rg-terraform-practice

