##################################################
# Salt Minion
##################################################
# variable "count" {}

variable "bastion_host" {}

variable "http_proxy_host" {}

variable "http_proxy_port" {}

variable "proxy_count" {}

variable "proxy_private_ips" {
  type = "list"
}

variable "etcd_count" {}

variable "etcd_private_ips" {
  type = "list"
}

variable "master_count" {}

variable "master_private_ips" {
  type = "list"
}

variable "node_count" {}

variable "node_private_ips" {
  type = "list"
}

variable "ssh_user" {
  default = "root"
}

variable "ssh_private_key" {
  default = "~/.ssh/id_rsa.insecure"
}

# variable "connections" {
#   type = "list"
# }

variable "salt_master_host" {}

resource "null_resource" "salt-minion-proxy" {
  count = "${var.proxy_count}"

  connection {
    type                = "ssh"
    host                = "${element(var.proxy_private_ips, count.index)}"
    user                = "${var.ssh_user}"
    private_key         = "${file(var.ssh_private_key)}"
    agent               = false
    bastion_host        = "${var.bastion_host}"
    bastion_user        = "${var.ssh_user}"
    bastion_private_key = "${file(var.ssh_private_key)}"
  }

  provisioner "remote-exec" {
    script = "${path.module}/scripts/salt-minion.sh"
  }

  provisioner "file" {
    content     = "master: ${var.salt_master_host}"
    destination = "/etc/salt/minion.d/master.conf"
  }

  provisioner "file" {
    content     = "role: proxy"
    destination = "/etc/salt/grains"
  }

  provisioner "file" {
    content = <<EOF
proxy_host: ${var.http_proxy_host}
proxy_port: ${var.http_proxy_port}
EOF

    destination = "/etc/salt/minion.d/proxy.conf"
  }

  provisioner "remote-exec" {
    inline = [
      "systemctl daemon-reload",
      "systemctl restart salt-minion",
    ]
  }
}

resource "null_resource" "salt-minion-etcd" {
  count = "${var.etcd_count}"

  connection {
    type                = "ssh"
    host                = "${element(var.etcd_private_ips, count.index)}"
    user                = "${var.ssh_user}"
    private_key         = "${file(var.ssh_private_key)}"
    agent               = false
    bastion_host        = "${var.bastion_host}"
    bastion_user        = "${var.ssh_user}"
    bastion_private_key = "${file(var.ssh_private_key)}"
  }

  provisioner "remote-exec" {
    script = "${path.module}/scripts/salt-minion.sh"
  }

  provisioner "file" {
    content     = "master: ${var.salt_master_host}"
    destination = "/etc/salt/minion.d/master.conf"
  }

  provisioner "file" {
    content     = "role: etcd"
    destination = "/etc/salt/grains"
  }

  provisioner "file" {
    content = <<EOF
proxy_host: ${var.http_proxy_host}
proxy_port: ${var.http_proxy_port}
EOF

    destination = "/etc/salt/minion.d/proxy.conf"
  }

  provisioner "remote-exec" {
    inline = [
      "systemctl daemon-reload",
      "systemctl restart salt-minion",
    ]
  }
}

resource "null_resource" "salt-minion-master" {
  count = "${var.master_count}"

  connection {
    type                = "ssh"
    host                = "${element(var.master_private_ips, count.index)}"
    user                = "${var.ssh_user}"
    private_key         = "${file(var.ssh_private_key)}"
    agent               = false
    bastion_host        = "${var.bastion_host}"
    bastion_user        = "${var.ssh_user}"
    bastion_private_key = "${file(var.ssh_private_key)}"
  }

  provisioner "remote-exec" {
    script = "${path.module}/scripts/salt-minion.sh"
  }

  provisioner "file" {
    content     = "master: ${var.salt_master_host}"
    destination = "/etc/salt/minion.d/master.conf"
  }

  provisioner "file" {
    content     = "role: master"
    destination = "/etc/salt/grains"
  }

  provisioner "file" {
    content = <<EOF
proxy_host: ${var.http_proxy_host}
proxy_port: ${var.http_proxy_port}
EOF

    destination = "/etc/salt/minion.d/proxy.conf"
  }

  provisioner "remote-exec" {
    inline = [
      "systemctl daemon-reload",
      "systemctl restart salt-minion",
    ]
  }
}

resource "null_resource" "salt-minion-node" {
  count = "${var.node_count}"

  connection {
    type                = "ssh"
    host                = "${element(var.node_private_ips, count.index)}"
    user                = "${var.ssh_user}"
    private_key         = "${file(var.ssh_private_key)}"
    agent               = false
    bastion_host        = "${var.bastion_host}"
    bastion_user        = "${var.ssh_user}"
    bastion_private_key = "${file(var.ssh_private_key)}"
  }

  provisioner "remote-exec" {
    script = "${path.module}/scripts/salt-minion.sh"
  }

  provisioner "file" {
    content     = "master: ${var.salt_master_host}"
    destination = "/etc/salt/minion.d/master.conf"
  }

  provisioner "file" {
    content     = "role: node"
    destination = "/etc/salt/grains"
  }

  provisioner "file" {
    content = <<EOF
proxy_host: ${var.http_proxy_host}
proxy_port: ${var.http_proxy_port}
EOF

    destination = "/etc/salt/minion.d/proxy.conf"
  }

  provisioner "remote-exec" {
    inline = [
      "systemctl daemon-reload",
      "systemctl restart salt-minion",
    ]
  }
}
