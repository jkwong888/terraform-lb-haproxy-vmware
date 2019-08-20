
##################################
#### Create the VMs
##################################
resource "vsphere_virtual_machine" "haproxy" {
  folder     = "${var.folder}"

  #####
  # VM Specifications
  ####
  resource_pool_id = "${var.vsphere_resource_pool_id}"

  name      = "${lower(var.instance_name)}-haproxy"
  num_cpus  = "${var.vcpu}"
  memory    = "${var.memory}"

  ####
  # Disk specifications
  ####
  datastore_id  = "${var.datastore_id}"
  guest_id      = "${data.vsphere_virtual_machine.template.guest_id}"
  scsi_type     = "${data.vsphere_virtual_machine.template.scsi_type}"

  disk {
      label            = "${lower(var.instance_name)}-haproxy.vmdk"
      size             = "${var.boot_disk["disk_size"]        != "" ? var.boot_disk["disk_size"]        : data.vsphere_virtual_machine.template.disks.0.size}"
      eagerly_scrub    = "${var.boot_disk["eagerly_scrub"]    != "" ? var.boot_disk["eagerly_scrub"]    : data.vsphere_virtual_machine.template.disks.0.eagerly_scrub}"
      thin_provisioned = "${var.boot_disk["thin_provisioned"] != "" ? var.boot_disk["thin_provisioned"] : data.vsphere_virtual_machine.template.disks.0.thin_provisioned}"
      keep_on_remove   = false
      unit_number      = 0
  }

  ####
  # Network specifications
  ####
  network_interface {
    network_id   = "${var.private_network_id}"
    adapter_type = "${data.vsphere_virtual_machine.template.network_interface_types[0]}"
  }

  network_interface {
    network_id   = "${var.public_network_id != "" ? var.public_network_id : var.private_network_id}"
    adapter_type = "${data.vsphere_virtual_machine.template.network_interface_types[0]}"
  }

  ####
  # VM Customizations
  ####
  clone {
    template_uuid = "${data.vsphere_virtual_machine.template.id}"

    customize {
      linux_options {
        host_name = "${lower(var.instance_name)}-haproxy"
        domain    = "${var.domain != "" ? var.domain : format("%s.local", var.instance_name)}"
      }
      network_interface {
        ipv4_address  = "${var.private_ip_address}"
        ipv4_netmask  = "${var.private_netmask}"
      }

      network_interface {
        ipv4_address  = "${var.public_network_id != "" ? var.public_ip_address : ""}"
        ipv4_netmask  = "${var.public_network_id != "" ? var.public_netmask : ""}"
      }

      ipv4_gateway    = "${var.gateway}"
      dns_server_list = "${var.dns_servers}"
    }
  }
}

