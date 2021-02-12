build {
  sources = ["source.amazon-ebs.arm64", "source.docker.image"]

  provisioner "shell" {
    only              = ["amazon-ebs"]
    expect_disconnect = true

    inline = [
      "cloud-init status --long --wait || (sleep 3; cat /var/log/cloud-init-output.log; sleep 3; exit 1)",
    ]
  }

  # For base images only - bootstrap the image with python and sudo so we can gather facts
  provisioner "ansible" {
    playbook_file   = "${local.ansible_dir}/bootstrap/playbook.yml"
  }

  provisioner "ansible" {
    user                 = "ubuntu"
    galaxy_file          = "${local.ansible_dir}/base/requirements.yml"
    galaxy_force_install = true

    playbook_file   = "${local.ansible_dir}/base/playbook.yml"

    extra_arguments                = [
      "--extra-vars", "apt_cleanup = true"
    ]
  }

  provisioner "shell" {
    only              = ["amazon-ebs"]
    expect_disconnect = true

    execute_command   = "sudo sh -c '{{ .Vars }} {{ .Path }}'"
    scripts           = ["${local.scripts_dir}/ubuntu-cleanup.sh"]
  }

  post-processors {
    post-processor "manifest" {
      only = ["amazon-ebs"]

      custom_data = {
        ami_name = "bainterfam/${var.ami_shortname}/ubuntu-${local.lts_versions[local.lcrelease]}-${local.timestamp}"
      }
    }
  }
}
