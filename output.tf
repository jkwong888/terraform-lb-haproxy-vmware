output "node_private_ip" {
    description = "IP addresses of created nodes"
    value          = "${local.haproxy_private_ip}"
}

output "node_public_ip" {
    description = "IP addresses of created nodes"
    value          = "${local.haproxy_public_ip}"
}


output "node_hostname" {
    description = "hostname of created nodes"
    value = "${var.datastore_id != "" ? "${vsphere_virtual_machine.haproxy.0.name}" : "${vsphere_virtual_machine.haproxy_ds_cluster.0.name}" }"
}