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

resource "azurerm_resource_group" "rg_primary" {
  name     = "rg-terraform-practice-${var.initialen}"
  location = var.location
  tags     = var.common_tags
}
