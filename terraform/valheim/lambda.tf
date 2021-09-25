data "archive_file" "lambda" {
  for_each = toset(["start", "stop"])

  type        = "zip"
  source_file = "${each.key}.js"
  output_path = "${each.key}.zip"
}

resource "aws_lambda_function" "valheim_control" {
  for_each = toset(["start", "stop"])

  function_name = "valheim-${each.key}"

  description = "${title(each.key)} the Valheim service"

  runtime = "nodejs12.x"
  role    = aws_iam_role.valheim_control_lambda.arn

  memory_size = 128
  timeout     = 300

  environment {
    variables = {
      CLUSTER = aws_ecs_cluster.valheim.arn
      SERVICE = aws_ecs_service.valheim.name
      SECRET  = "shared/valheim/server_pass"
      BUCKET  = aws_s3_bucket.valheim_usw2.id
    }
  }


  handler = "${each.key}.handler"

  filename         = "${each.key}.zip"
  source_code_hash = data.archive_file.lambda[each.key].output_base64sha256
}
