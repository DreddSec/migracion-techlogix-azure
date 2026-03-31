terraform {
  backend "azurerm" {
    resource_group_name  = "rg-techlogix-prod"
    storage_account_name = "sttechlogixprod"
    container_name       = "tfstate"
    key                  = "techlogix.prod.tfstate"
  }

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 3.0"
    }
  }
  required_version = ">= 1.3.0"
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

provider "azuread" {}
