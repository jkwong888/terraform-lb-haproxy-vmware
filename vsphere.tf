##################################
#### Collect resource IDs
##################################
data "vsphere_virtual_machine" "template" {
  name            = "${var.template}"
  datacenter_id   = "${var.vsphere_datacenter_id}"
}

provider "vsphere" {
  version        = "~> 1.1"
  vsphere_server = "${var.vsphere_server}"

  # if you have a self-signed cert
  allow_unverified_ssl = "${var.vsphere_allow_unverified_ssl}"

}
