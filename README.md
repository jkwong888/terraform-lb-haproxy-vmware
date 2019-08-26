# terraform-lb-haproxy

Terraform module that creates an HAProxy VM as a stand-in for a load balancer (for example, for a PoC).  We don't recommend usage of standalone HAProxy in production scenarios as it is a single point of failure.

The load balancer VM can be either on two networks or one.  Note that only one of `datastore_id` or `datastore_cluster_id` should be specified, depending on if Storage DRS is enabled in your vSphere instance.  

A RHEL 7.x VM template with a valid subscription should be used as a template.

Here is an example usage from [openshift example](https://github.com/ibm-cloud-architecture/terraform-openshift4-vmware-example):

```
module "control_plane_lb" {
    source                  = "https://github.com/ibm-cloud-architecture/terraform-lb-haproxy-vmware"

    providers = {
        vsphere = "vsphere"
    }

    vsphere_server          = "${var.vsphere_server}"
    allow_unverified_ssl    = "${var.allow_unverified_ssl}"
    
    vsphere_datacenter_id = "${data.vsphere_datacenter.dc.id}"
    vsphere_cluster_id = "${data.vsphere_compute_cluster.cluster.id}"
    vsphere_resource_pool_id = "${data.vsphere_resource_pool.pool.id}"
    datastore_id = "${var.datastore != "" ? "${data.vsphere_datastore.datastore.0.id}" : ""}"
    datastore_cluster_id = "${var.datastore_cluster != "" ? "${data.vsphere_datastore_cluster.datastore_cluster.0.id}" : ""}"
    template = "${var.rhel_template}"

    # Folder to provision the new VMs in, does not need to exist in vSphere
    folder = "${local.folder}"
    instance_name = "${var.name}-console"

    private_network_id = "${data.vsphere_network.network.id}"
    private_ip_address = "${var.control_plane_ip_address}"
    private_netmask = "${var.netmask}"
    public_network_id = ""

    gateway = "${var.gateway}"
    dns_servers = "${var.dns_servers}"

    ssh_user                = "${var.ssh_user}"
    ssh_password            = "${var.ssh_password}"
    ssh_private_key         = "${file(var.ssh_keyfile)}"

    frontend = ["6443", "22623"]
    backend = {
        "6443" = "${join(",", compact(concat(var.control_plane_ip_addresses, list(var.bootstrap_complete ? "" : var.bootstrap_ip_address))))}",
        "22623" = "${join(",", compact(concat(var.control_plane_ip_addresses, list(var.bootstrap_complete ? "" : var.bootstrap_ip_address))))}"
    }

}
```