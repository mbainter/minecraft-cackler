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
