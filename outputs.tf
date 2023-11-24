output "private_ip_addresses" {
  description = "Private addresses of vms"
  value = {
    "haproxy_private_ip_addresses" = ["${openstack_compute_instance_v2.haproxy.*.network.0.fixed_ip_v4}"]
    "apache_private_ip_addresses"  = ["${openstack_compute_instance_v2.apache.*.network.0.fixed_ip_v4}"]
    "ansible_private_ip_addresses" = ["${openstack_compute_instance_v2.ansible.*.network.0.fixed_ip_v4}"]
  }
}

output "haproxy_float_ip" {
  value = openstack_networking_floatingip_v2.haproxy_fip.address
}

output "private_key" {
  value     = tls_private_key.ssh_key.private_key_pem
  sensitive = true
}

output "http_url" {
  value = "http://${openstack_networking_floatingip_v2.haproxy_fip.address}"
}
