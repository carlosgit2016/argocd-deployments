terraform {
  backend "s3" {
    bucket  = "cflor-personal-terraform-state"
    key     = "argocd-deployments/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  required_version = "~> 1.7.3"
}
