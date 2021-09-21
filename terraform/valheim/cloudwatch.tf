resource "aws_cloudwatch_log_group" "valheim" {
  name = "valheim"

  retention_in_days = 3

  tags = {
    Application = "Valheim"
  }
}

resource "aws_cloudwatch_log_group" "valheim_mordheim" {
  name = "valheim/ecs/mordheim"

  retention_in_days = 3

  tags = {
    Application = "Valheim"
  }
}

resource "aws_cloudwatch_log_group" "valheim_lambda" {
  for_each = toset(["start", "stop"])

  name = "/aws/lambda/valheim-${each.key}"

  retention_in_days = 3

  tags = {
    Application = "Valheim"
  }
}
