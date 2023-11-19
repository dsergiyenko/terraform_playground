#### Create Apache1 Instance ####
resource "openstack_compute_instance_v2" "apache" {
  count            = var.apache_vm_count
  name             = format("%s-%d", "apache", count.index+1)
  flavor_name      = "d1.ram2cpu1"
  security_groups  = [openstack_compute_secgroup_v2.security_group.name]
  depends_on = [
    openstack_networking_network_v2.private_network,
    openstack_blockstorage_volume_v3.disk_apache
  ]
  network {
    uuid           = openstack_networking_network_v2.private_network.id
    fixed_ip_v4 = "192.168.0.11${count.index+1}"
  }
  block_device {
    uuid           = openstack_blockstorage_volume_v3.disk_apache[count.index].id
    boot_index     = 0
    source_type    = "volume"
    destination_type = "volume"
    delete_on_termination = false
  }

  user_data = data.template_file.bootstrap_script.rendered
}

#### Create Disk for Apache####
resource "openstack_blockstorage_volume_v3" "disk_apache" {
  count            = var.apache_vm_count
  name             = format("%s-%d", "disk_apache", count.index)
  volume_type      = "ceph-ssd" #type: ceph-backup, ceph-ssd, ceph-hdd
  size             = "10"
  image_id         = var.image_id
  enable_online_resize = "true" 
}
