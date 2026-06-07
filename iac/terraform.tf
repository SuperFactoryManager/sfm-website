terraform {
  required_version = ">= 1.12.0"

  backend "azurerm" {
    subscription_id      = "6cb7032f-2437-4f5e-91e8-676cb67e5444"
    resource_group_name  = "CACN-Terraform-PROD-RG"
    storage_account_name = "terraformproddwvc87"
    container_name       = "statefiles"
    key                  = "sfm-website-prod.tfstate"
  }

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.74.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "3.1.0"
    }
  }
}
