resource "aws_security_group" "prospector" {
  name        = "prospector"
  description = "Prospector Lambda Function"

  vpc_id = data.aws_vpc.target.id

  tags = {
    Name = "prospector"
  }
}

resource "aws_security_group_rule" "prospector_allow_slack_http" {
  security_group_id = aws_security_group.prospector.id
  description       = "Allow slack connections to prospector lambda"

  type      = "ingress"
  from_port = 80
  to_port   = 80
  protocol  = "tcp"
  #tfsec:ignore:AWS006
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "prospector_allow_slack_https" {
  security_group_id = aws_security_group.prospector.id
  description       = "Allow slack connections to prospector lambda"

  type      = "ingress"
  from_port = 443
  to_port   = 443
  protocol  = "tcp"
  #tfsec:ignore:AWS006
  cidr_blocks = ["0.0.0.0/0"]
}
