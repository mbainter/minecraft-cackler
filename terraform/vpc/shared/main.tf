module "default_vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "2.70.0"

  azs = ["us-west-2a", "us-west-2b", "us-west-2c"]

  private_subnets = ["10.10.0.0/24", "10.10.1.0/24", "10.10.2.0/24"]
  private_subnet_tags = {
    Type = "private"
  }

  public_subnets = ["10.10.100.0/24", "10.10.101.0/24", "10.10.102.0/24"]
  public_subnet_tags = {
    Type             = "public"
    PackerAllowed    = "true"
    MinecraftAllowed = "true"
  }

  name = "shared"
  cidr = "10.10.0.0/16"

  enable_nat_gateway = false
  enable_vpn_gateway = false

  vpc_tags = {
    PackerAllowed = "true"
  }

  tags = {
    Terraform = "true"
  }
}
