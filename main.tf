
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

#### Create security group #####
resource "openstack_compute_secgroup_v2" "security_group" {
  name             = "sg_all"
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

resource "openstack_compute_secgroup_v2" "security_group_haproxy" {
  name             = "sg_haproxy"
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
  rule {
    from_port      = 80
    to_port        = 80
    ip_protocol    = "tcp"
    cidr           = "0.0.0.0/0"
       } 
}

#### Create Disk ####
resource "openstack_blockstorage_volume_v3" "disk" {
  name             = "volume_name"
  volume_type      = "ceph-ssd" #type: ceph-backup, ceph-ssd, ceph-hdd
  size             = "10"
  image_id         = var.image_id
  enable_online_resize = "true" 
                                                   }

resource "openstack_blockstorage_volume_v3" "disk_ansible" {
  name             = "volume_name"
  volume_type      = "ceph-ssd" #type: ceph-backup, ceph-ssd, ceph-hdd
  size             = "10"
  image_id         = var.image_id
  enable_online_resize = "true" 
                                                   }

#### Create Instanse ####
resource "openstack_compute_instance_v2" "haproxy" {
  name             = "haproxy"
  flavor_name      = "d1.ram2cpu1"
  key_pair         = openstack_compute_keypair_v2.ssh.name
  security_groups  = [openstack_compute_secgroup_v2.security_group_haproxy.name]
  depends_on = [
                openstack_networking_network_v2.private_network,
                openstack_blockstorage_volume_v3.disk
]
  network {
    uuid           = openstack_networking_network_v2.private_network.id
    fixed_ip_v4 = "192.168.0.101"
          }
  block_device {
    uuid           = openstack_blockstorage_volume_v3.disk.id
    boot_index     = 0
    source_type    = "volume"
    destination_type = "volume"
    delete_on_termination = false
               }
#  user_data = file("bootstrap_other_hosts.sh")
  user_data = data.template_file.bootstrap_script.rendered

  connection {
    type        = "ssh"
    user        = "centos"  # or your SSH user
    private_key = "${tls_private_key.ssh_key.private_key_pem}"
    host        = "${openstack_networking_floatingip_v2.haproxy_fip.address}"
  }
                                                   }

#### Create Ansible Instance ####
resource "openstack_compute_instance_v2" "ansible" {
  name             = "ansible"
  flavor_name      = "d1.ram2cpu1"
#  key_pair         = openstack_compute_keypair_v2.ssh.name
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
#  user_data = file("bootstrap_ansible_host.sh")
  user_data = data.template_file.bootstrap_script.rendered
}

#### Assign floating IP ####
resource "openstack_compute_floatingip_associate_v2" "haproxy_fip_association" {
  floating_ip      = openstack_networking_floatingip_v2.haproxy_fip.address
  instance_id      = openstack_compute_instance_v2.haproxy.id
  fixed_ip         = openstack_compute_instance_v2.haproxy.access_ip_v4
                                                                                }


resource "null_resource" "install_ansible_on_vm" {
  depends_on = [
    openstack_compute_instance_v2.haproxy
  ]
  provisioner "remote-exec" {
    inline = [
    "sudo yum -y install epel-release", 
    "sudo yum -y install ansible -y", 
    "echo ansible INSTALLED",
    "cd /home/centos",
    "wget https://11459ansible.object.pscloud.io/ansible.zip",
    "unzip ansible.zip",
    "cd ansible",
    "ansible-playbook -i inventory.ini playbooks/bootstrap_hosts.yml"
    ]

    connection {
#      host        = "${openstack_networking_floatingip_v2.haproxy_fip.address}"
      host        = "${openstack_compute_instance_v2.ansible.network.0.fixed_ip_v4}"
      type        = "ssh"
      user        = "centos"
#      private_key = "${file("/home/sergiyenko/.ssh/id_rsa")}"
      private_key = "${tls_private_key.ssh_key.private_key_pem}"
      bastion_host = openstack_networking_floatingip_v2.haproxy_fip.address
    }
  }

}
