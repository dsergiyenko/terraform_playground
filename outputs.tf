output "haproxy_private_ip" {
    value = openstack_compute_instance_v2.haproxy.access_ip_v4
}
output "ansible_private_ip" {
    value = openstack_compute_instance_v2.ansible.access_ip_v4
}
output "apache1_private_ip" {
    value = openstack_compute_instance_v2.apache1.access_ip_v4
}
output "apache2_private_ip" {
    value = openstack_compute_instance_v2.apache2.access_ip_v4
}
output "apache3_private_ip" {
    value = openstack_compute_instance_v2.apache3.access_ip_v4
}

output "haproxy_float_ip" {
    value = openstack_networking_floatingip_v2.haproxy_fip.address
}

output "private_key" {
  value = tls_private_key.ssh_key.private_key_pem
  sensitive = true
}

output "url" {
  value = "curl ${openstack_networking_floatingip_v2.haproxy_fip.address}"
}

output "http_url" {
  value = "http://${openstack_networking_floatingip_v2.haproxy_fip.address}"
}
