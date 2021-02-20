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

data "aws_ami" "ubuntu_arm64" {
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "name"
    values = ["bainterfam/base/ubuntu-18.04-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }

  filter {
    name   = "architecture"
    values = ["arm64"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

#data "aws_ami" "ubuntu_amd64" {
#  most_recent = true
#  owners      = ["self"]
#
#  filter {
#    name   = "name"
#    values = ["bainterfam/base/ubuntu-18.04-*"]
#  }
#
#  filter {
#    name   = "virtualization-type"
#    values = ["hvm"]
#  }
#
#  filter {
#    name   = "state"
#    values = ["available"]
#  }
#
#  filter {
#    name   = "architecture"
#    values = ["amd64"]
#  }
#
#  filter {
#    name   = "root-device-type"
#    values = ["ebs"]
#  }
#}
