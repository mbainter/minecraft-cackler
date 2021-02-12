source "docker" "image" {
  image        = "ubuntu:${local.lts_versions[local.lcrelease]}"
  export_path  = "${var.ami_shortname}.tar"
}

source "amazon-ebs" "amd64" {
  ami_name             = "bainterfam/${var.ami_shortname}/ubuntu-${local.lts_versions[local.lcrelease]}-${local.timestamp}"

  run_tags = {
    Name = "Packer - Temporary for building ${var.ami_shortname} AMI ${local.timestamp}"
  }

  run_volume_tags = {
    Name = "Packer - Temporary for building ${var.ami_shortname} AMI ${local.timestamp}"
  }

  source_ami_filter {
    filters = {
      name                = "*ubuntu/images/hvm-ssd/ubuntu-${local.lcrelease}-${local.lts_versions[local.lcrelease]}-amd64-server-*",
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }

  launch_block_device_mappings {
      device_name           = "/dev/sda1"
      volume_size           = 10
      volume_type           = "gp3"
      delete_on_termination = true
      encrypted             = true

  }

  ami_block_device_mappings {
      device_name           = "/dev/sda1"
      volume_size           = 10
      volume_type           = "gp3"
      delete_on_termination = true
  }

  communicator         = "ssh"
  ssh_interface        = "session_manager"
  #ssh_keypair_name     = "packer"
  #ssh_private_key_file = var.ssh_key_file
  ssh_username         = "ubuntu"

  region    = "us-west-2"

  vpc_filter {
    filters = {
      "isDefault": "false",
      "tag:PackerAllowed": "true"
    }
  }

  subnet_filter {
    filters   = {
      "tag:PackerAllowed": "true"
    }
    most_free = true
  }

  security_group_filter {
    filters = {
      "tag:PackerAllowed": "true"
    }
  }

  instance_type       = var.instance_type
  enable_t2_unlimited = var.enable_t2_unlimited
  user_data_file      = "${local.userdata_dir}/basic.sh"
  shutdown_behavior   = "terminate"

  iam_instance_profile = "${var.instance_profile}"

  tags = merge(local.common_tags,
    {
      Name        = "${local.release}-${title(var.ami_shortname)}"
      Provisioner = "Ansible"
    }
  )
}

source "amazon-ebs" "arm64" {
  ami_name             = "bainterfam/${var.ami_shortname}/ubuntu-${local.lts_versions[local.lcrelease]}-${local.timestamp}"

  run_tags = {
    Name = "Packer - Temporary for building ${var.ami_shortname} AMI ${local.timestamp}"
  }

  run_volume_tags = {
    Name = "Packer - Temporary for building ${var.ami_shortname} AMI ${local.timestamp}"
  }

  source_ami_filter {
    filters = {
      name                = "*ubuntu/images/hvm-ssd/ubuntu-${local.lcrelease}-${local.lts_versions[local.lcrelease]}-arm64-server-*",
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }

  communicator         = "ssh"
  ssh_interface        = "session_manager"
  #ssh_keypair_name     = "packer"
  #ssh_private_key_file = var.ssh_key_file
  ssh_username         = "ubuntu"

  region    = "us-west-2"

  vpc_filter {
    filters = {
      "isDefault": "false",
      "tag:PackerAllowed": "true"
    }
  }

  subnet_filter {
    filters   = {
      "tag:PackerAllowed": "true"
    }
    most_free = true
  }

  security_group_filter {
    filters = {
      "tag:PackerAllowed": "true"
    }
  }


  instance_type        = "t4g.large"
  #enable_t2_unlimited = var.enable_unlimited_cpu
  user_data_file       = "${local.userdata_dir}/basic.sh"
  shutdown_behavior    = "terminate"

  iam_instance_profile = "${var.instance_profile}"

  tags = merge(local.common_tags,
    {
      Name        = "${local.release}-${title(var.ami_shortname)}"
      Provisioner = "Ansible"
    }
  )
}
