variable "az" {
  type        = string
  description = "The availability zone to launch in. This is where the EBS volume will be, so it cannot be changed w/out additional effort"
}

variable "mc_instance_type" {
  type        = string
  description = "Instance type to use for the Minecraft servers"
}
