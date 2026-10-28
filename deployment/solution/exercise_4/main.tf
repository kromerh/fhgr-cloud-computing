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

module "primary" {
  source = "./modules/rg-stac-cont"

  name        = "primary"
  initialen   = var.initialen
  location    = var.location
  common_tags = var.common_tags
}

module "secondary" {
  source = "./modules/rg-stac-cont"

  name        = "secondary"
  initialen   = var.initialen
  location    = var.location
  common_tags = var.common_tags
}

module "tertiary" {
  source = "./modules/rg-stac-cont"

  name        = "tertiary"
  initialen   = var.initialen
  location    = var.location
  common_tags = var.common_tags
}
