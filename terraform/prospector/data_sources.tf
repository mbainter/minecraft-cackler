data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

data "aws_vpc" "target" {
  filter {
    name   = "tag:Name"
    values = ["shared"]
  }
}

data "aws_subnet_ids" "public" {
  vpc_id = data.aws_vpc.target.id

  filter {
    name   = "state"
    values = ["available"]
  }

  filter {
    name   = "availability-zone"
    values = [var.az]
  }

  filter {
    name   = "tag:Type"
    values = ["public"]
  }
}
