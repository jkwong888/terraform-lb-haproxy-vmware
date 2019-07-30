##################################
#### Collect resource IDs
##################################
data "vsphere_virtual_machine" "template" {
  name            = "${var.template}"
  datacenter_id   = "${var.vsphere_datacenter_id}"
}

