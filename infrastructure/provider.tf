provider "aws" {
  default_tags {
    tags = {
      "billing"              = "personal"
      "product"              = "personal"
      "environment"          = "lowers"
      "primary-contact-name" = "carlosggflor@gmail.com"
    }
  }

  region = "us-east-1"
}