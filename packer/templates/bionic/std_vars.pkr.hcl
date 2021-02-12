locals {
  userdata_dir  = "${path.root}/../../userdata/"
  scripts_dir  = "${path.root}/../../scripts/"
  files_dir    = "${path.root}/../../files/"
  ansible_dir  = "${path.root}/../../ansible"

  timestamp = regex_replace(timestamp(), "[- TZ:]", "")

  #github_ssh_key = aws_secretsmanager("packer/github", null)
  github_ssh_key  = ""

  common_tags = {
    BaseAMI                = "{{.SourceAMITags.BaseAMI}}"
    BuildDate              = "${local.timestamp}"
    Distribution           = "Ubuntu"
    Name                   = "bainterfam-${local.lcrelease}-${var.ami_shortname}"
    Release                = local.release
    SourceAMI              = "{{.SourceAMI}}"
    SourceAMIName          = "{{.SourceAMIName}}"
  }

  lts_versions = {
    bionic     = "18.04"
    focal      = "20.04"
  }

  lcrelease = lower(var.ubuntu_release)
  release   = title(var.ubuntu_release)
}

variable "ami_shortname" {
  description = "Shortname for the AMI suffix (no spaces)"
  type        = string
}

variable "ubuntu_release" {
  description = "The name of the Ubuntu release"
  type        = string
}

variable "instance_type" {
  type    = string
  default = "t2.large"
}

variable "enable_unlimited_cpu" {
  type    = bool
  default = true
}

variable "subnet_id" {
  default = "subnet-33b49718"
}

variable "instance_profile" {
  type    = string
  default = "packer-build"
}

variable "ssh_key_file" {
  sensitive = true
  type      = string
}

variable "aws_profile" {
  type    = string
  default = "mc"
}

variable "lifecycled_version" {
  type    = string
  default = "3.0.2"
}
