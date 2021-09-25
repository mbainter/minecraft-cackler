data "aws_region" "current" {}

data "aws_region" "us-east-2" {
  provider = aws.us-east-2
  name = "us-east-2"
}

data "aws_caller_identity" "current" {}
