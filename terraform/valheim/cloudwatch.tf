resource "aws_cloudwatch_log_group" "valheim" {
  name = "valheim"

  retention_in_days = 3

  tags = {
    Application = "Valheim"
  }
}
