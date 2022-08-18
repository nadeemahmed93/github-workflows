provider "azurerm" {​​​​​​​
  version = "=2.32.0"
  features {​​​​​​​}​​​​​​​
}​​​​​​​


provider "kubernetes" {​​​​​​​
  version = "=1.13.2"
}​​​​​​​


terraform {​​​​​​​
  required_version = ">= 0.13.5, < 1.0"
  backend "azurerm" {​​​​​​​
    resource_group_name  = ""
    storage_account_name = "tfstate0"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }​​​​​​​
}​​​​​​​
 




