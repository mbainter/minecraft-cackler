variable "docker_image" {
  type        = string
  description = "Docker image to use for the Fargate tasks"
  default     = "ghcr.io/lloesche/valheim-server:latest"
}

variable "world_name" {
  type        = string
  description = "The world name for the instance"
  default     = "mordheim"
}

variable "status_port" {
  type        = number
  description = "The status port for the world"
  default     = 80
}

variable "cpu" {
  type        = number
  description = "CPU value for Valheim task"
}

variable "memory" {
  type        = number
  description = "Memory size for Valheim task"
}

variable "valheim_backups_bucket" {
  type        = string
  description = "Name of the S3 bucket to use for backups"
}

variable "valheim_backups_admins" {
  type        = list(any)
  description = "List of administrator users for the S3 bucket"
  default     = []
}

variable "valheim_backups_ro" {
  type        = list(any)
  description = "List of read-only users for the S3 bucket"
  default     = []
}
