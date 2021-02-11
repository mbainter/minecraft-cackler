resource "aws_security_group" "packer" {
  name        = "packer-builds"
  description = "Used by packer for building new AMIs"

  vpc_id = module.default_vpc.vpc_id

  tags = {
    Name          = "packer-build"
    PackerAllowed = "true"
  }
}

resource "aws_security_group_rule" "packer_allow_ssh" {
  security_group_id = aws_security_group.packer.id
  description       = "Allow SSH to packer instances"

  type      = "ingress"
  from_port = 22
  to_port   = 22
  protocol  = "tcp"
  #tfsec:ignore:AWS006
  cidr_blocks = ["0.0.0.0/0"]
}
