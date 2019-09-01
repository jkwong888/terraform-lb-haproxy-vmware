# terraform-lb-haproxy

Terraform module that creates an HAProxy VM in VMware as a stand-in for a load balancer (for example, for a PoC).  We don't recommend usage of standalone HAProxy in production scenarios as it is a single point of failure.

The load balancer VM can be either on two networks or one.  Note that only one of `datastore_id` or `datastore_cluster_id` should be specified, depending on if Storage DRS is enabled in your vSphere instance.  

A RHEL 7.x VM template with a valid subscription should be used as a template.  You can register the VM against RHN if you set the `rhn_*` variables corresponding to your subscription.

Here is an example usage from [openshift example](https://github.com/ibm-cloud-architecture/terraform-openshift3-vmware-example):

```terraform
module "console_loadbalancer" {
    source                  = "github.com/ibm-cloud-architecture/terraform-lb-haproxy-vmware?ref=v1.0"

    # vsphere connection parameters and resources
    vsphere_server                  = "<vsphere_server>"
    vsphere_allow_unverified_ssl    = "true"

    vsphere_datacenter_id     = "<datacenter id>"
    vsphere_cluster_id        = "<cluster id>"
    vsphere_resource_pool_id  = "<resource pool ID>"
    datastore_id              = "<datastore ID, leave blank is specifying datastore cluster>"
    datastore_cluster_id      = "<datastore cluster ID, leave blank if specifying datastore>"
    folder_path               = "<folder path>"

    instance_name             = "<prefix of VM and hostname, we append "-haproxy" to the end>"

    # private network settings
    private_network_id  = "<vsphere private network id>"
    private_ip_address  = "<private ip to assign to lb>"
    private_netmask     = "<netmask of subnet, e.g. "24">"
    private_gateway     = "<gateway for private network>"
    private_domain      = "<private network domain>"

    # <optional> public network settings, leave blank if single network
    public_network_id   = "<vsphere public network id>"
    public_ip_address   = "<public ip address to assign to lb>"
    public_netmask      = "<netmask of subnet, e.g. "24">
    public_gateway      = "<gateway for public network, becomes default route>"
    public_domain       = "<public network domain>"

    # added to /etc/resolv.conf, note that both private and public network domains are added to the search list>
    dns_servers         = ["<dns1>", "<dns2>"]

    # how to ssh into the template, user must have passwordless sudo
    template                         = "<template name>"
    template_ssh_user                = "<ssh user>"
    template_ssh_private_key         = "<ssh_private_key>"

    # if the VM is provisioned on a private network, SSH using this connection
    bastion_ip_address       = "<ssh public ip>"
    bastion_ssh_user         = "<ssh user>"
    bastion_ssh_private_key  = "<ssh user>"

    # if we need to register the template with RHN
    rhn_username       = "${var.rhn_username}"
    rhn_password       = "${var.rhn_password}"
    rhn_poolid         = "${var.rhn_poolid}"

    # ports to configure, for now the IPs must listen on the same ports as the frontend
    frontend = ["443"]
    backend = {
        "443" = ["<ip1>", "<ip2>", "<ip3>"]
    }
}
```