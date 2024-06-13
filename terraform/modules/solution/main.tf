provider "azurerm" {  
  features {}  
}

module "primary" {  
  source = "./modules/tg/stac-cont"  
  name   = "primary"  
}  

module "secondary" {  
  source = "./modules/tg/stac-cont"  
  name   = "secondary"  
}  

module "tertiary" {  
  source = "./modules/tg/stac-cont"  
  name   = "tertiary"  
}  
