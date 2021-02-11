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

resource "aws_security_group_rule" "packer_allow_all_out" {
  security_group_id = aws_security_group.packer.id
  description       = "Allow all outbound access for Packer"

  type      = "egress"
  from_port = 0
  to_port   = 65535
  protocol  = "all"
  #tfsec:ignore:AWS007
  cidr_blocks = ["0.0.0.0/0"]
}

#resource "aws_security_group" "ssm_endpoint" {
#  name        = "ssm-endpoints"
#  description = "Security group for controlling SSM Endpoint Access"
#
#  vpc_id = module.default_vpc.vpc_id
#
#  tags = {
#    Name = "ssm-endpoints"
#  }
#}

#resource "aws_security_group_rule" "ssm_allow_all_out" {
#  security_group_id = aws_security_group.packer.id
#  description       = "Allow all outbound access for SSM"
#
#  type      = "egress"
#  from_port = 0
#  to_port   = 65535
#  protocol  = "all"
#  #tfsec:ignore:AWS007
#  cidr_blocks = ["0.0.0.0/0"]
#}
