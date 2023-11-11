resource "openstack_compute_keypair_v2" "ssh" {
  name             = "keypair_name"
  public_key       = "${var.ssh_public_key}"
}

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
