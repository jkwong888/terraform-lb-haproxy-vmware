resource "null_resource" "dependency" {
  triggers = {
    all_dependencies = "${join(",", var.dependson)}"
  }
}

locals {
  haproxy_ip = "${var.datastore_cluster_id == "" ? "${vsphere_virtual_machine.haproxy.0.default_ip_address}" : "${vsphere_virtual_machine.haproxy_ds_cluster.0.default_ip_address}" }"
}

resource "null_resource" "install_haproxy" {
    depends_on = [
      "null_resource.dependency"
    ]
   
    connection {
        type     = "ssh"
        host     = "${local.haproxy_ip}"
        user     = "${var.ssh_user}"
        password = "${var.ssh_password}"
        private_key = "${var.ssh_private_key}"

        bastion_host = "${var.bastion_ip_address}"
        bastion_password = "${var.bastion_ssh_password}"
        bastion_host_key = "${var.bastion_ssh_private_key}"
    }

    provisioner "remote-exec" {
        when = "create"
        inline = [
            "sudo subscription-manager repos --disable='*'",
            "sudo subscription-manager repos --enable='rhel-7-server-rpms'",
            "sudo yum -y install haproxy"
        ]
    }
}

resource "null_resource" "open_ports_firewalld" {
    count = "${length(var.frontend)}"

    connection {
        type     = "ssh"
        host     = "${local.haproxy_ip}"
        user     = "${var.ssh_user}"
        password = "${var.ssh_password}"
        private_key = "${var.ssh_private_key}"

        bastion_host = "${var.bastion_ip_address}"
        bastion_password = "${var.bastion_ssh_password}"
        bastion_host_key = "${var.bastion_ssh_private_key}"
    }

    provisioner "remote-exec" {
        when = "create"
        inline = [
            "sudo firewall-cmd --zone=public --add-port=${element(var.frontend, count.index)}/tcp"
        ]
    }
}

resource "null_resource" "selinux_allow" {
    connection {
        type     = "ssh"
        host     = "${local.haproxy_ip}"
        user     = "${var.ssh_user}"
        password = "${var.ssh_password}"
        private_key = "${var.ssh_private_key}"

        bastion_host = "${var.bastion_ip_address}"
        bastion_password = "${var.bastion_ssh_password}"
        bastion_host_key = "${var.bastion_ssh_private_key}"
    }

    provisioner "remote-exec" {
        when = "create"
        inline = [
            "sudo setsebool -P haproxy_connect_any=1"
        ]
    }
}

data "template_file" "haproxy_config_global" {
    template = <<EOF
global
    user haproxy
    group haproxy
    daemon
    maxconn 4096
EOF
}

data "template_file" "haproxy_config_defaults" {
    template = <<EOF
defaults
    mode    tcp
    balance leastconn
    timeout client      30000ms
    timeout server      30000ms
    timeout connect      3000ms
    retries 3
EOF
}

data "template_file" "haproxy_config_frontend" {
    count = "${length(var.frontend)}"

    template = <<EOF
frontend fr_server${element(var.frontend, count.index)}
  bind 0.0.0.0:${element(var.frontend, count.index)}
  default_backend bk_server${element(var.frontend, count.index)}
EOF
}

data "template_file" "haproxy_config_backend" {
    count = "${length(keys(var.backend))}"

    template = <<EOF
backend bk_server${element(keys(var.backend), count.index)}
  balance roundrobin
${join("\n", formatlist("  server srv%v %v:%v check fall 3 rise 2 maxconn 2048", split(",", lookup(var.backend, element(keys(var.backend), count.index))), split(",", lookup(var.backend, element(keys(var.backend), count.index))), element(keys(var.backend), count.index)))}
EOF
}

resource "null_resource" "haproxy_cfg" {
    depends_on = [
        "null_resource.install_haproxy",
        "null_resource.selinux_allow"
    ]

    triggers = {
        defaults = "${data.template_file.haproxy_config_defaults.rendered}"
        global = "${data.template_file.haproxy_config_global.rendered}"
        frontend = "${join(",", data.template_file.haproxy_config_frontend.*.rendered)}"
        backend = "${join(",", data.template_file.haproxy_config_backend.*.rendered)}"
    }

    connection {
        type = "ssh"
        host     = "${local.haproxy_ip}"
        user     = "${var.ssh_user}"
        password = "${var.ssh_password}"
        private_key = "${var.ssh_private_key}"

        bastion_host = "${var.bastion_ip_address}"
        bastion_password = "${var.bastion_ssh_password}"
        bastion_host_key = "${var.bastion_ssh_private_key}"
    }

    provisioner "file" {
        content     = <<EOF
${data.template_file.haproxy_config_global.rendered}
${data.template_file.haproxy_config_defaults.rendered}
${join("\n", data.template_file.haproxy_config_frontend.*.rendered)}
${join("\n", data.template_file.haproxy_config_backend.*.rendered)}
EOF
        destination = "/tmp/haproxy.cfg"
    }

    provisioner "remote-exec" {
        inline = [
            "sudo haproxy -c -f /tmp/haproxy.cfg",
            "sudo cp /tmp/haproxy.cfg /etc/haproxy/haproxy.cfg",
            "sudo systemctl restart haproxy"
        ]
    }
}