
#### Create the VMs
##################################
resource "vsphere_virtual_machine" "haproxy" {
  count     = "${var.datastore_id != "" ? 1 : 0}"
  folder     = "${var.folder_path}"

  #####
  # VM Specifications
  ####
  resource_pool_id = "${var.vsphere_resource_pool_id}"

  name      = "${lower(var.instance_name)}-lb"
  num_cpus  = "${var.vcpu}"
  memory    = "${var.memory}"

  ####
  # Disk specifications
  ####
  datastore_id  = "${var.datastore_id}"
  guest_id      = "${data.vsphere_virtual_machine.template.guest_id}"
  scsi_type     = "${data.vsphere_virtual_machine.template.scsi_type}"

  disk {
      label            = "disk0"
      size             = "${var.boot_disk["disk_size"]        != "" ? var.boot_disk["disk_size"]        : data.vsphere_virtual_machine.template.disks.0.size}"
      eagerly_scrub    = "${var.boot_disk["eagerly_scrub"]    != "" ? var.boot_disk["eagerly_scrub"]    : data.vsphere_virtual_machine.template.disks.0.eagerly_scrub}"
      thin_provisioned = "${var.boot_disk["thin_provisioned"] != "" ? var.boot_disk["thin_provisioned"] : data.vsphere_virtual_machine.template.disks.0.thin_provisioned}"
      keep_on_remove   = false
      unit_number      = 0
  }

  ####
  # Network specifications
  ####
  dynamic "network_interface" {
    for_each = compact(concat(list(var.public_network_id, var.private_network_id)))
    content {
      network_id   = "${network_interface.value}"
      adapter_type = "${data.vsphere_virtual_machine.template.network_interface_types[0]}"
    }
  }

  ####
  # VM Customizations
  ####
  clone {
    template_uuid = "${data.vsphere_virtual_machine.template.id}"

    customize {
      linux_options {
        host_name = "${lower(var.instance_name)}-lb"
        domain    = "${var.private_domain != "" ? var.private_domain : format("%s.local", var.instance_name)}"
      }

      dynamic "network_interface" {
        for_each = compact(concat(list(var.public_ip_address, var.private_ip_address)))
        content {
          ipv4_address = "${network_interface.value}"
          ipv4_netmask = "${element(compact(concat(list(var.public_netmask), list(var.private_netmask))), network_interface.key)}"
        }
      }

      ipv4_gateway    = "${var.public_gateway != "" ? var.public_gateway : var.private_gateway}"
      dns_server_list = "${var.dns_servers}"
      dns_suffix_list = compact(list(var.private_domain, var.public_domain))
    }
  }
}


resource "vsphere_virtual_machine" "haproxy_ds_cluster" {
  count     = "${var.datastore_cluster_id != "" ? 1 : 0}"
  folder    = "${var.folder_path}"

  #####
  # VM Specifications
  ####
  resource_pool_id = "${var.vsphere_resource_pool_id}"

  name      = "${lower(var.instance_name)}-lb"
  num_cpus  = "${var.vcpu}"
  memory    = "${var.memory}"

  ####
  # Disk specifications
  ####
  datastore_cluster_id  = "${var.datastore_cluster_id}"
  guest_id      = "${data.vsphere_virtual_machine.template.guest_id}"
  scsi_type     = "${data.vsphere_virtual_machine.template.scsi_type}"

  disk {
      label            = "disk0"
      size             = "${var.boot_disk["disk_size"]        != "" ? var.boot_disk["disk_size"]        : data.vsphere_virtual_machine.template.disks.0.size}"
      eagerly_scrub    = "${var.boot_disk["eagerly_scrub"]    != "" ? var.boot_disk["eagerly_scrub"]    : data.vsphere_virtual_machine.template.disks.0.eagerly_scrub}"
      thin_provisioned = "${var.boot_disk["thin_provisioned"] != "" ? var.boot_disk["thin_provisioned"] : data.vsphere_virtual_machine.template.disks.0.thin_provisioned}"
      keep_on_remove   = false
      unit_number      = 0
  }

  ####
  # Network specifications
  ####
  dynamic "network_interface" {
    for_each = compact(concat(list(var.public_network_id, var.private_network_id)))
    content {
      network_id   = "${network_interface.value}"
      adapter_type = "${data.vsphere_virtual_machine.template.network_interface_types[0]}"
    }
  }

  ####
  # VM Customizations
  ####
  clone {
    template_uuid = "${data.vsphere_virtual_machine.template.id}"

    customize {
      linux_options {
        host_name = "${lower(var.instance_name)}-lb"
        domain    = "${var.private_domain != "" ? var.private_domain : format("%s.local", var.instance_name)}"
      }

      dynamic "network_interface" {
        for_each = compact(concat(list(var.public_ip_address, var.private_ip_address)))
        content {
          ipv4_address = "${network_interface.value}"
          ipv4_netmask = "${element(compact(concat(list(var.public_netmask), list(var.private_netmask))), network_interface.key)}"
        }
      }

      ipv4_gateway    = "${var.public_gateway != "" ? var.public_gateway : var.private_gateway}"
      dns_server_list = "${var.dns_servers}"
      dns_suffix_list = compact(list(var.private_domain, var.public_domain))
    }
  }
  

}