####################################
#### vSphere Access Credentials ####
####################################
variable "vsphere_server" {
  description = "vsphere server to connect to"
  default     = "___INSERT_YOUR_OWN____"
}

# Set username/password as environment variables VSPHERE_USER and VSPHERE_PASSWORD

variable "vsphere_allow_unverified_ssl" {
  description = "Allows terraform vsphere provider to communicate with vsphere servers with self signed certificates"
  default     = "true"
}

##############################################
##### vSphere deployment specifications ######
##############################################

variable "vsphere_datacenter_id" {
  description = "ID of the vsphere datacenter to deploy to"
  default     = "___INSERT_YOUR_OWN____"
}

variable "vsphere_cluster_id" {
  description = "ID of vsphere cluster to deploy to"
  default     = "___INSERT_YOUR_OWN____"
}

variable "vsphere_resource_pool_id" {
  description = "ID resource pool to deploy to."
  default     = ""
}

variable "private_network_id" {
  description = "ID of network to provision VMs on. All VMs will be provisioned on the same network"
  default     = "___INSERT_YOUR_OWN____"
}

variable "public_network_id" {
  description = "ID of network to provision VMs on. All VMs will be provisioned on the same network"
  default     = ""
}

variable "datastore_id" {
  description = "ID of datastore to use for the VMs, only set one of datastore_id or datastore_cluster_id"
  default     = ""
}

variable "datastore_cluster_id" {
  description = "ID of datastore cluster to use for the VMs, only set one of datastore_id or datastore_cluster_id"
  default     = ""
}


## Note
# Because of https://github.com/terraform-providers/terraform-provider-vsphere/issues/271 templates must be converted to VMs on ESX 5.5 (and possibly other)
variable "template" {
  description = "Name of template or VM to clone for the VM creations. "
  default     = "___INSERT_YOUR_OWN____"
}

variable "folder_path" {
  description = "Path of VM Folder to provision the new VMs in. The folder must exist"
  default     = ""
}

variable "instance_name" {
  description = "Name of the ICP installation, will be used as basename for VMs"
  default     = "icptest"
}

variable "private_domain" {
  description = "domain of the private interface"
}

variable "private_ip_address" {
  description = "Specify IP address"
}

variable "public_ip_address" {
  description = "Specify public IP address"
  default     = ""
}

variable "public_gateway" {
  description = "Default gateway for the newly provisioned VMs. Leave blank to use DHCP"
  default     = ""
}

variable "private_gateway" {
  description = "Default gateway for the newly provisioned VMs. Leave blank to use DHCP"
}

variable "private_netmask" {
  description = "Netmask in CIDR notation when using static IPs. For example 16 or 24. Set to 0 to retrieve from DHCP"
}

variable "public_netmask" {
  description = "Netmask in CIDR notation when using static IPs. For example 16 or 24. Set to 0 to retrieve from DHCP"
  default     = ""
}

variable "public_domain" {
  description = "domain of the public interface"
  default = ""
}


variable "dns_servers" {
  description = "DNS Servers to configure on VMs"
  default     = ["8.8.8.8", "8.8.4.4"]
}

#################################
##### ICP Instance details ######
#################################
variable "vcpu" {
  default = 1
}

variable "memory" {
  default = 2048
}

variable "boot_disk" {
  type = map

  default = {
    disk_size             = ""      # Specify size or leave empty to use same size as template.
    thin_provisioned      = "true"      # True or false. Whether to use thin provisioning on the disk. Leave blank to use same as template
    eagerly_scrub         = "false"      # True or false. If set to true disk space is zeroed out on VM creation. Leave blank to use same as template
    keep_disk_on_remove   = "false" # Set to 'true' to not delete a disk on removal.
  }
}

variable "bastion_ip_address" {
  default = ""
}

variable "bastion_ssh_user" {
  default = ""
}

variable "bastion_ssh_private_key" {
  default = ""
}

variable "bastion_ssh_password" {
  default = ""
}

variable "template_ssh_private_key" {
  default = ""
}

variable "template_ssh_user" {
  default = ""
}

variable "template_ssh_password" {
  default = ""
}

variable "frontend" {
  type = list
  default = []
  description = "list of frontend listener ports"
}

variable "backend" {
  type = map
  default = {}
  description = "map of frontend listener ports to backend IP addresses, comma separated string"
}

variable "dependson" {
    type = list
    default = []
}

####################################
# RHN Registration
####################################
variable "rhn_username" {
  description = "deprecated"
  default = ""
}

variable "rhn_password" {
  description = "deprecated"
  default = ""

}
variable "rhn_poolid" {
  description = "deprecated"
  default = ""
}

variable "install_from_epel" {
  description = "install haproxy from epel, useful if you don't want to subscribe to RHN"
  default = "true"
}
