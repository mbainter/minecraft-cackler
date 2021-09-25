locals {
  account_id = data.aws_caller_identity.current.account_id
  region     = data.aws_region.current.name

  region_use2 = data.aws_region.us-east-2.name
}
