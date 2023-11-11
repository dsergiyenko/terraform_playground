
#### Import SSH key ####
resource "openstack_compute_keypair_v2" "ssh" {
  name             = "keypair_name"
  public_key       = "${var.ssh_public_key}"
                                              }
#### End Import block ####

#### Create Network ####
resource "openstack_networking_network_v2" "private_network" {
  name             = "network_name"
  admin_state_up   = "true"
                                                             }
#### End Network block ####
#### Сreate subnet ####
resource "openstack_networking_subnet_v2" "private_subnet" {
  name             = "subnet_name"
  network_id       = openstack_networking_network_v2.private_network.id
  cidr             = "192.168.0.0/24"
  dns_nameservers  = [
                      "195.210.46.195",
                      "195.210.46.132"
                     ]
  ip_version       = 4
  enable_dhcp      = true
  depends_on = [openstack_networking_network_v2.private_network]
                                                           }
#### End subnet block ####
#### Create Router ####
resource "openstack_networking_router_v2" "router" {
  name             = "router_name"
  external_network_id = "83554642-6df5-4c7a-bf55-21bc74496109" #UUID of the floating ip network
  admin_state_up   = "true"
  depends_on = [openstack_networking_network_v2.private_network]
                                                   }
#### End router block ####
#### Adding interface to the router ####
resource "openstack_networking_router_interface_v2" "router_interface" {
  router_id        = openstack_networking_router_v2.router.id
  subnet_id        = openstack_networking_subnet_v2.private_subnet.id
  depends_on       = [openstack_networking_router_v2.router]
                                                                       }
#### End interface block ####
#### Allocate ip to the project ####
resource "openstack_networking_floatingip_v2" "haproxy_fip" {
  pool             = "FloatingIP Net"
                                                             }
#### End Allocate IP block ####
#### Create security group #####
resource "openstack_compute_secgroup_v2" "security_group" {
  name             = "sg_name"
  description      = "open all icmp, and ssh"
  
  rule {
    from_port      = 22
    to_port        = 22
    ip_protocol    = "tcp"
    cidr           = "0.0.0.0/0"
       }
  
  rule {
    from_port      = -1
    to_port        = -1
    ip_protocol    = "icmp"
    cidr           = "0.0.0.0/0"
       }                                                         
}

#### End security group block ####
#### Create Disk ####
resource "openstack_blockstorage_volume_v3" "disk" {
  name             = "volume_name"
  volume_type      = "ceph-ssd" #type: ceph-backup, ceph-ssd, ceph-hdd
  size             = "10"
  image_id         = var.image_id
  enable_online_resize = "true" 
                                                   }
#### End Create disk block ####
#### Create Instanse ####
resource "openstack_compute_instance_v2" "haproxy" {
  name             = "haproxy"
  flavor_name      = "d1.ram2cpu1"
  key_pair         = openstack_compute_keypair_v2.ssh.name
  security_groups  = [openstack_compute_secgroup_v2.security_group.name]
  depends_on = [
                openstack_networking_network_v2.private_network,
                openstack_blockstorage_volume_v3.disk
]
  network {
    uuid           = openstack_networking_network_v2.private_network.id
          }
  block_device {
    uuid           = openstack_blockstorage_volume_v3.disk.id
    boot_index     = 0
    source_type    = "volume"
    destination_type = "volume"
    delete_on_termination = false
               }
                                                   }
#### End Create Instans block ####
#### Assign floating IP ####
resource "openstack_compute_floatingip_associate_v2" "haproxy_fip_association" {
  floating_ip      = openstack_networking_floatingip_v2.haproxy_fip.address
  instance_id      = openstack_compute_instance_v2.haproxy.id
  fixed_ip         = openstack_compute_instance_v2.haproxy.access_ip_v4
                                                                                }
#### End Assign floadting IP block ####
