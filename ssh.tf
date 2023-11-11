resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
}

data "template_file" "bootstrap_script" {
  template = file("./bootstrap_hosts.sh")

  vars = {
    private_key = tls_private_key.ssh_key.private_key_pem
    public_key  = tls_private_key.ssh_key.public_key_openssh
  }
}
