output "haproxy_private_ip" {
    value = openstack_compute_instance_v2.haproxy.access_ip_v4
}

output "ansible_private_ip" {
    value = openstack_compute_instance_v2.ansible.access_ip_v4
}

output "haproxy_float_ip" {
    value = openstack_networking_floatingip_v2.haproxy_fip.address
}

output "private_key" {
  value = tls_private_key.ssh_key.private_key_pem
  sensitive = true
}

output "public_key" {
  value = <<EOT
  paste in terminal to connect via ssh:
  ssh centos@${openstack_networking_floatingip_v2.haproxy_fip.address}
  EOT
}
