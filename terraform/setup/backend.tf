terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27.0"
    }
  }

  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "bainterfam"

    workspaces {
      name = "terraform"
    }
  }
}
