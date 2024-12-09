provider "azurerm" {
  features {}
}

module "primary" {
  source = "./modules/rg-stac-cont"
  name   = "primary"
}

module "secondary" {
  source = "./modules/rg-stac-cont"
  name   = "secondary"
}

module "tertiary" {
  source = "./modules/rg-stac-cont"
  name   = "tertiary"
}
