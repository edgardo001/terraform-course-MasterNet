terraform {
    required_providers {
      azurerm = {
        source = "hashicorp/azurerm"
        version = "4.47.0"
      }
    }

    backend "azurerm" {
      resource_group_name = "nu-iac-dev-eus-rg"
      storage_account_name = "nuiacdeveusac"
      container_name = "terraform"
      key= "terraform.tfstate"
    }

}

provider "azurerm" {
    features {
    }

    subscription_id = var.subscription_id
}