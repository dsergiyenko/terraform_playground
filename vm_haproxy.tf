#### Create Haproxy Instanse ####
resource "openstack_compute_instance_v2" "haproxy" {
  count           = var.haproxy_vm_count
  name            = format("%s-%d", "haproxy", count.index + 1)
  flavor_name     = "d1.ram2cpu1"
  security_groups = [openstack_compute_secgroup_v2.security_group.name]
  depends_on = [
    openstack_networking_network_v2.private_network,
    openstack_blockstorage_volume_v3.disk_haproxy
  ]
  network {
    uuid        = openstack_networking_network_v2.private_network.id
    fixed_ip_v4 = "192.168.0.10${count.index + 1}"
  }
  block_device {
    uuid                  = openstack_blockstorage_volume_v3.disk_haproxy[count.index].id
    boot_index            = 0
    source_type           = "volume"
    destination_type      = "volume"
    delete_on_termination = false
  }

  user_data = data.template_file.bootstrap_script.rendered

  connection {
    type        = "ssh"
    user        = "centos" # or your SSH user
    private_key = tls_private_key.ssh_key.private_key_pem
    host        = openstack_networking_floatingip_v2.haproxy_fip.address
  }
}

#### Create Disk for Haproxy####
resource "openstack_blockstorage_volume_v3" "disk_haproxy" {
  count                = var.haproxy_vm_count
  name                 = format("%s-%d", "disk_haproxy", count.index)
  volume_type          = "ceph-ssd" #type: ceph-backup, ceph-ssd, ceph-hdd
  size                 = "10"
  image_id             = var.image_id
  enable_online_resize = "true"
}
