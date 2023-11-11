#### Create Apache1 Instance ####
resource "openstack_compute_instance_v2" "apache1" {
  name             = "apache1"
  flavor_name      = "d1.ram2cpu1"
  security_groups  = [openstack_compute_secgroup_v2.security_group_haproxy.name]
  depends_on = [
    openstack_networking_network_v2.private_network,
    openstack_blockstorage_volume_v3.disk_apache1
  ]
  network {
    uuid           = openstack_networking_network_v2.private_network.id
    fixed_ip_v4 = "192.168.0.111"
  }
  block_device {
    uuid           = openstack_blockstorage_volume_v3.disk_apache1.id
    boot_index     = 0
    source_type    = "volume"
    destination_type = "volume"
    delete_on_termination = false
  }

  user_data = data.template_file.bootstrap_script.rendered
}

#### Create Disk for Apache1####
resource "openstack_blockstorage_volume_v3" "disk_apache1" {
  name             = "volume_name"
  volume_type      = "ceph-ssd" #type: ceph-backup, ceph-ssd, ceph-hdd
  size             = "10"
  image_id         = var.image_id
  enable_online_resize = "true" 
}

#### Create Apache2 Instance ####
resource "openstack_compute_instance_v2" "apache2" {
  name             = "apache2"
  flavor_name      = "d1.ram2cpu1"
  security_groups  = [openstack_compute_secgroup_v2.security_group_haproxy.name]
  depends_on = [
    openstack_networking_network_v2.private_network,
    openstack_blockstorage_volume_v3.disk_apache2
  ]
  network {
    uuid           = openstack_networking_network_v2.private_network.id
    fixed_ip_v4 = "192.168.0.112"
  }
  block_device {
    uuid           = openstack_blockstorage_volume_v3.disk_apache2.id
    boot_index     = 0
    source_type    = "volume"
    destination_type = "volume"
    delete_on_termination = false
  }

  user_data = data.template_file.bootstrap_script.rendered
}

#### Create Disk for Apache2####
resource "openstack_blockstorage_volume_v3" "disk_apache2" {
  name             = "volume_name"
  volume_type      = "ceph-ssd" #type: ceph-backup, ceph-ssd, ceph-hdd
  size             = "10"
  image_id         = var.image_id
  enable_online_resize = "true" 
}

#### Create Apache3 Instance ####
resource "openstack_compute_instance_v2" "apache3" {
  name             = "apache3"
  flavor_name      = "d1.ram2cpu1"
  security_groups  = [openstack_compute_secgroup_v2.security_group_haproxy.name]
  depends_on = [
    openstack_networking_network_v2.private_network,
    openstack_blockstorage_volume_v3.disk_apache3
  ]
  network {
    uuid           = openstack_networking_network_v2.private_network.id
    fixed_ip_v4 = "192.168.0.113"
  }
  block_device {
    uuid           = openstack_blockstorage_volume_v3.disk_apache3.id
    boot_index     = 0
    source_type    = "volume"
    destination_type = "volume"
    delete_on_termination = false
  }

  user_data = data.template_file.bootstrap_script.rendered
}

#### Create Disk for Apache3####
resource "openstack_blockstorage_volume_v3" "disk_apache3" {
  name             = "volume_name"
  volume_type      = "ceph-ssd" #type: ceph-backup, ceph-ssd, ceph-hdd
  size             = "10"
  image_id         = var.image_id
  enable_online_resize = "true" 
}
