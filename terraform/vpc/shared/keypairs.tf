resource "aws_key_pair" "packer" {
  key_name   = "packer"
  public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIARf9n2BQxaYoPUtP6fu3cLW9/1pFiz4YHkCCsnRH5dd packer"
}
