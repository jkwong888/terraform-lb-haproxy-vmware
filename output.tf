output "node_ip" {
    description = "IP addresses of created nodes"
    value = "${vsphere_virtual_machine.haproxy.default_ip_address}"
}

output "node_hostname" {
    description = "hostname of created nodes"
    value = "${vsphere_virtual_machine.haproxy.name}"
}