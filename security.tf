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
