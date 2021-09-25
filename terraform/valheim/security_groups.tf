resource "aws_security_group" "valheim" {
  name        = "valheim-servers"
  description = "Valheim servers"

  vpc_id = data.aws_vpc.target.id

  tags = {
    Name      = "Valheim"
    ManagedBy = "Terraform"
  }
}

resource "aws_security_group_rule" "valheim_allow_games" {
  security_group_id = aws_security_group.valheim.id
  description       = "Allow game connections to Valheim instances"

  type      = "ingress"
  from_port = 2456
  to_port   = 2456
  protocol  = "udp"
  #tfsec:ignore:AWS006
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "security_group_icmp_type_3_in" {
  security_group_id = aws_security_group.valheim.id
  description       = "ICMP destination unreachable messages inbound"
  type              = "ingress"
  protocol          = "icmp"
  #tfsec:ignore:AWS006
  cidr_blocks = ["0.0.0.0/0"]
  from_port   = 3
  to_port     = -1
}

resource "aws_security_group_rule" "security_group_icmp_type_8_in" {
  security_group_id = aws_security_group.valheim.id
  description       = "ICMP echo request messages inbound"
  type              = "ingress"
  protocol          = "icmp"
  #tfsec:ignore:AWS006
  cidr_blocks = ["0.0.0.0/0"]
  from_port   = 8
  to_port     = 0
}

resource "aws_security_group_rule" "security_group_icmp_type_11_in" {
  security_group_id = aws_security_group.valheim.id
  description       = "ICMP destination unreachable messages inbound"
  type              = "ingress"
  protocol          = "icmp"
  #tfsec:ignore:AWS006
  cidr_blocks = ["0.0.0.0/0"]
  from_port   = 11
  to_port     = 0
}

resource "aws_security_group_rule" "valheim_allow_status" {
  security_group_id = aws_security_group.valheim.id
  description       = "Allow status connections to Valheim instances"

  type      = "ingress"
  from_port = var.status_port
  to_port   = var.status_port
  protocol  = "tcp"
  #tfsec:ignore:AWS006
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "valheim_allow_tcp_outbound" {
  security_group_id = aws_security_group.valheim.id
  description       = "Allow outbound TCP connections"

  type      = "egress"
  from_port = 0
  to_port   = 65535
  protocol  = "tcp"
  #tfsec:ignore:AWS007
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "valheim_allow_udp_outbound" {
  security_group_id = aws_security_group.valheim.id
  description       = "Allow outbound UDP connections"

  type      = "egress"
  from_port = 0
  to_port   = 65535
  protocol  = "udp"
  #tfsec:ignore:AWS007
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "valheim_allow_icmp_outbound" {
  security_group_id = aws_security_group.valheim.id
  description       = "Allow outbound icmp connections"

  type      = "egress"
  from_port = -1
  to_port   = -1
  protocol  = "icmp"
  #tfsec:ignore:AWS007
  cidr_blocks = ["0.0.0.0/0"]
}
