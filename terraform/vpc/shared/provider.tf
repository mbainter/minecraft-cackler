variable "allowed_account_id" {
  type        = string
  description = "AWS Account to modify"
}

provider "aws" {
  region              = "us-west-2"
  allowed_account_ids = [var.allowed_account_id]
}

provider "aws" {
  alias   = "us-east-2"
  region  = "us-east-2"

  allowed_account_ids = [var.allowed_account_id]
}
