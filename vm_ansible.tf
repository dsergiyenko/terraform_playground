#### Create Ansible Instance ####
resource "openstack_compute_instance_v2" "ansible" {
  name             = "ansible"
  flavor_name      = "d1.ram2cpu1"
  security_groups  = [openstack_compute_secgroup_v2.security_group.name]
  depends_on = [
    openstack_networking_network_v2.private_network,
    openstack_blockstorage_volume_v3.disk_ansible
  ]
  network {
    uuid           = openstack_networking_network_v2.private_network.id
    fixed_ip_v4 = "192.168.0.100"
  }
  block_device {
    uuid           = openstack_blockstorage_volume_v3.disk_ansible.id
    boot_index     = 0
    source_type    = "volume"
    destination_type = "volume"
    delete_on_termination = false
  }
  user_data = data.template_file.bootstrap_script.rendered
}

resource "openstack_blockstorage_volume_v3" "disk_ansible" {
  name             = "volume_name"
  volume_type      = "ceph-ssd" #type: ceph-backup, ceph-ssd, ceph-hdd
  size             = "10"
  image_id         = var.image_id
  enable_online_resize = "true" 
}

resource "null_resource" "install_ansible_on_vm" {
  depends_on = [
    openstack_compute_instance_v2.haproxy,
    openstack_compute_instance_v2.apache,
    openstack_compute_instance_v2.ansible
  ]

  #generate dynamic inventory for ansible
  provisioner "file" {
    destination = "/tmp/inventory.ini"
    content     = <<-EOT
    [haproxy]
    %{ for instance in openstack_compute_instance_v2.haproxy.* }
    ${instance.name} ansible_host=${instance.network.0.fixed_ip_v4} ansible_user=centos
    %{ endfor }
    [apache]
    %{ for instance in openstack_compute_instance_v2.apache.* }
    ${instance.name} ansible_host=${instance.network.0.fixed_ip_v4} ansible_user=centos
    %{ endfor }
    EOT
  }

  provisioner "remote-exec" {
    inline = [
    "sudo yum -y install epel-release", 
    "sudo yum -y install ansible -y", 
    "cd /home/centos",
    "wget https://11459ansible.object.pscloud.io/ansible.zip",
    "unzip -o ansible.zip",
    "cd ansible",
    "cp /tmp/inventory.ini /home/centos/ansible/inventory/inventory.ini",
    "ansible-playbook -i inventory/inventory.ini playbooks/bootstrap_hosts.yml"
    ]
  }

  connection {
    host        = "${openstack_compute_instance_v2.ansible.network.0.fixed_ip_v4}"
    type        = "ssh"
    user        = "centos"
    private_key = "${tls_private_key.ssh_key.private_key_pem}"
    bastion_host = openstack_networking_floatingip_v2.haproxy_fip.address
  }

}
