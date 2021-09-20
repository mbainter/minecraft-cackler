resource "aws_ecs_cluster" "valheim" {
  name = "valheim-cluster"

  capacity_providers = ["FARGATE_SPOT"]

  default_capacity_provider_strategy {
    capacity_provider = "FARGATE_SPOT"
    weight            = 1
  }
}

locals {
  install_awscli = [
    "curl \"https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip\" -o \"awscliv2.zip\"",
    "unzip awscliv2.zip",
    "./aws/install",
    "aws --version"
  ]
  task_environment = {
    SERVER_NAME                   = var.world_name,
    SERVER_PORT                   = 2456,
    WORLD_NAME                    = var.world_name,
    SERVER_PUBLIC                 = true,
    UPDATE_INTERVAL               = 900,
    BACKUPS_INTERVAL              = 1800,
    BACKUPS_DIRECTORY             = "/config/backups",
    BACKUPS_MAX_AGE               = 3,
    BACKUPS_DIRECTORY_PERMISSIONS = 755,
    BACKUPS_FILE_PERMISSIONS      = 644,
    CONFIG_DIRECTORY_PERMISSIONS  = 755,
    WORLDS_DIRECTORY_PERMISSIONS  = 755,
    WORLDS_FILE_PERMISSIONS       = 644,
    DNS_1                         = "10.10.0.2",
    DNS_2                         = "10.10.0.2",
    STEAMCMD_ARGS                 = "validate",
    STATUS_HTTP_PORT              = var.status_port,
    POST_BOOTSTRAP_HOOK           = join(" && ", local.install_awscli)
    PRE_SERVER_RUN_HOOK           = "aws s3 sync s3://${var.valheim_backups_bucket}/worlds /config/worlds --delete"
    POST_SERVER_SHUTDOWN_HOOK     = "aws s3 sync /config/worlds s3://${var.valheim_backups_bucket}/worlds --delete"
    POST_BACKUP_HOOK              = "aws s3 sync /config/backups s3://${var.valheim_backups_bucket}/backups --delete"
  }

  container_definition = {
    name   = var.world_name
    image  = var.docker_image
    cpu    = var.cpu
    memory = var.memory

    portMappings = [
      {
        hostPort      = var.status_port
        containerPort = var.status_port
        protocol      = "tcp"
      },
      {
        hostPort      = 2456
        containerPort = 2456
        protocol      = "udp"
      },
      {
        hostPort      = 2457
        containerPort = 2457
        protocol      = "udp"
      },
      {
        hostPort      = 2458
        containerPort = 2458
        protocol      = "udp"
      }
    ]

    environment = [for k, v in local.task_environment : { name = k, value = tostring(v) }]

    secrets = [
      {
        name      = "SERVER_PASS"
        valueFrom = "shared/valheim/server_pass"
      }
    ]

    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-region        = local.region
        awslogs-group         = "valheim"
        awslogs-stream-prefix = "ecs"
      }
    }
  }
}

resource "aws_ecs_task_definition" "valheim" {
  family                   = "valheim"
  execution_role_arn       = aws_iam_role.valheim_exec.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.cpu
  memory                   = var.memory
  task_role_arn            = aws_iam_role.valheim_backup.arn
  container_definitions    = jsonencode([local.container_definition])
}

resource "aws_ecs_service" "valheim" {
  depends_on = [
    aws_iam_policy.valheim_exec,
  ]
  name                   = "valheim"
  cluster                = aws_ecs_cluster.valheim.id
  task_definition        = aws_ecs_task_definition.valheim.arn
  desired_count          = 0
  launch_type            = "FARGATE"
  enable_execute_command = true

  network_configuration {
    subnets          = data.aws_subnet_ids.public.ids
    security_groups  = [aws_security_group.valheim.id]
    assign_public_ip = true
  }

  lifecycle {
    ignore_changes = [desired_count]
  }
}
