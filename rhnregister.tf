locals {
    nodes_to_register = compact(list(var.rhn_username != "" ? local.haproxy_private_ip : ""))
}

module "rhnregister" {
  source             = "github.com/ibm-cloud-architecture/terraform-openshift-rhnregister"

  ssh_user          = "${var.template_ssh_user}"
  ssh_password      = "${var.template_ssh_password}"
  ssh_private_key   = "${var.template_ssh_private_key}"

  bastion_ip_address      = "${var.bastion_ip_address}"
  bastion_ssh_user        = "${var.bastion_ssh_user}"
  bastion_ssh_password    = "${var.bastion_ssh_password}"
  bastion_ssh_private_key = "${var.bastion_ssh_private_key}"

  rhn_username       = "${var.rhn_username}"
  rhn_password       = "${var.rhn_password}"
  rhn_poolid         = "${var.rhn_poolid}"

  all_nodes          = local.nodes_to_register
  all_count          = "${var.rhn_username != "" ? 1 : 0}"
}