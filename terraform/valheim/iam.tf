data "aws_iam_policy_document" "ecs_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "valheim_exec" {
  name               = "valheim_exec"
  assume_role_policy = data.aws_iam_policy_document.ecs_assume_role.json
}

resource "aws_iam_role_policy_attachment" "valheim_ecs_exec" {
  role       = aws_iam_role.valheim_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "valheim_exec" {
  role       = aws_iam_role.valheim_exec.name
  policy_arn = aws_iam_policy.valheim_exec.arn
}

resource "aws_iam_policy" "valheim_exec" {
  name        = "valheim-exec-access"
  path        = "/"
  description = "Access policy for Valheim to run"

  policy = data.aws_iam_policy_document.valheim_exec.json
}

data "aws_iam_policy_document" "valheim_exec" {
  #   statement {
  #     actions = [
  #       "secretsmanager:DescribeSecret",
  #       "secretsmanager:GetSecretValue"
  #     ]
  #     resources = [aws_secretsmanager_secret.valheim.arn]
  #   }

  statement {
    sid = "ParameterStoreListAccess"

    actions = [
      "ssm:DescribeParameters"
    ]

    resources = ["*"]
  }

  statement {
    sid = "ParameterStoreReadAccess"

    actions = [
      "ssm:GetParameter",
      "ssm:GetParameters",
      "ssm:GetParametersByPath"
    ]

    resources = [
      "arn:aws:ssm:${local.region}:${local.account_id}:parameter/shared/valheim/*",
    ]
  }
}

resource "aws_iam_role" "valheim_backup" {
  name               = "valheim_backup"
  assume_role_policy = data.aws_iam_policy_document.ecs_assume_role.json
}

resource "aws_iam_role_policy_attachment" "valheim_backup" {
  role       = aws_iam_role.valheim_backup.name
  policy_arn = aws_iam_policy.valheim_backup.arn
}

resource "aws_iam_policy" "valheim_backup" {
  name        = "valheim-backup-access"
  path        = "/"
  description = "Access policy to backup Valheim"

  policy = data.aws_iam_policy_document.valheim_backup.json
}

data "aws_iam_policy_document" "valheim_backup" {
  statement {
    sid = "S3BucketAccess"

    actions = [
      "s3:GetBucketLocation",
      "s3:ListBucketMultipartUploads",
      "s3:ListBucket",
      "s3:ListBucketVersions",
    ]

    resources = [
      aws_s3_bucket.valheim.arn,
    ]
  }

  statement {
    sid = "S3ObjectAccess"

    actions = [
      "s3:PutObject*",
      "s3:GetObject*",
      "s3:DeleteObject",
      "s3:AbortMultipartUpload",
      "s3:ListMultipartUploadParts",
    ]

    resources = [
      "${aws_s3_bucket.valheim.arn}/*",
    ]
  }

  statement {
    sid = "ParameterStoreListAccess"

    actions = [
      "ssm:DescribeParameters"
    ]

    resources = ["*"]
  }

  statement {
    sid = "ParameterStoreReadAccess"

    actions = [
      "ssm:GetParameter",
      "ssm:GetParameters",
      "ssm:GetParametersByPath"
    ]

    resources = [
      "arn:aws:ssm:${local.region}:${local.account_id}:parameter/shared/valheim/*",
    ]
  }
}
