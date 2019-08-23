output "node_ip" {
    description = "IP addresses of created nodes"
    value = "${var.datastore_id != "" ? "${vsphere_virtual_machine.haproxy.0.default_ip_address}" : "${vsphere_virtual_machine.haproxy_ds_cluster.0.default_ip_address}" }"
}

output "node_hostname" {
    description = "hostname of created nodes"
    value = "${var.datastore_id != "" ? "${vsphere_virtual_machine.haproxy.0.name}" : "${vsphere_virtual_machine.haproxy_ds_cluster.0.name}" }"
}