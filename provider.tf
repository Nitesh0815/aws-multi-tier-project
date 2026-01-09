############################################
# Terraform & Provider Configuration
############################################

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# AWS provider
# Region is controlled via variables for flexibility
provider "aws" {
  region = var.region
}
