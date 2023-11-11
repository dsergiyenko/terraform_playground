#### Create Network ####
resource "openstack_networking_network_v2" "private_network" {
  name             = "network_name"
  admin_state_up   = "true"
}

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

#### Create Router ####
resource "openstack_networking_router_v2" "router" {
  name             = "router_name"
  external_network_id = "83554642-6df5-4c7a-bf55-21bc74496109" #UUID of the floating ip network
  admin_state_up   = "true"
  depends_on = [openstack_networking_network_v2.private_network]
}

#### Adding interface to the router ####
resource "openstack_networking_router_interface_v2" "router_interface" {
  router_id        = openstack_networking_router_v2.router.id
  subnet_id        = openstack_networking_subnet_v2.private_subnet.id
  depends_on       = [openstack_networking_router_v2.router]
}

#### Allocate ip to the project ####
resource "openstack_networking_floatingip_v2" "haproxy_fip" {
  pool             = "FloatingIP Net"
}

#### Assign floating IP to Haproxy VM####
resource "openstack_compute_floatingip_associate_v2" "haproxy_fip_association" {
  floating_ip      = openstack_networking_floatingip_v2.haproxy_fip.address
  instance_id      = openstack_compute_instance_v2.haproxy.id
  fixed_ip         = openstack_compute_instance_v2.haproxy.access_ip_v4
}
