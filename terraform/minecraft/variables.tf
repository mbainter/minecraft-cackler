variable "az" {
  type        = string
  description = "The availability zone to launch in. This is where the EBS volume will be, so it cannot be changed w/out additional effort"
}

variable "live_mc_instance_type" {
  type        = string
  description = "Instance type to use for the Test Minecraft servers"
}

variable "test_mc_instance_type" {
  type        = string
  description = "Instance type to use for the Live Minecraft servers"
}

variable "minecraft_backups_bucket" {
  type        = string
  description = "Name of the S3 bucket to use for backups"
}

variable "minecraft_backups_admins" {
  type        = list(any)
  description = "List of administrator users for the S3 bucket"
}

variable "minecraft_backups_ro" {
  type        = list(any)
  description = "List of read-only users for the S3 bucket"
}
