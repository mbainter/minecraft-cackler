# resource "aws_secretsmanager_secret" "valheim" {
#   name = "valheim"
#   policy = data.aws_iam_policy_document.valheim_secret.json
# }
# 
# data aws_iam_policy_document "valheim_secret" {
#   statement {
#     actions = [
#       "secretsmanager:DescribeSecret",
#       "secretsmanager:GetSecretValue"
#     ]
#     resources = ["*"]
# 
#     principals {
#       type        = "AWS"
#       identifiers = setunion([data.aws_iam_role.sre.arn], var.secret_read_role_arns)
#     }
#   }
# }
