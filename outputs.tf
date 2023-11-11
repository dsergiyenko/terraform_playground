output "instance_ip" {
    value = openstack_compute_instance_v2.haproxy.access_ip_v4
}

output "float_ip" {
    value = openstack_networking_floatingip_v2.haproxy_fip.address
}
