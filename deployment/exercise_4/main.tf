terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 5.11"
    }
  }
}

provider "azurerm" {
  features {}
  resource_providers_to_register = [
    "Microsoft.Compute", "Microsoft.Network", "Microsoft.Storage"
  ]
}
