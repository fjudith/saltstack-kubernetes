##################################################
# Salt Minion
##################################################
# variable "count" {}

resource "null_resource" "salt-minion-edge" {
  count = var.edge_count

  connection {
    type                = "ssh"
    host                = element(var.edge_private_ips, count.index)
    user                = var.ssh_user
    private_key         = file(var.ssh_private_key)
    agent               = false
    bastion_host        = var.bastion_host
    bastion_user        = var.ssh_user
    bastion_private_key = file(var.ssh_private_key)
  }

  provisioner "remote-exec" {
    script = "${path.module}/scripts/salt-minion.sh"
  }

  provisioner "file" {
    content     = element(data.template_file.master-conf.*.rendered, count.index)
    destination = "/etc/salt/minion.d/master.conf"
  }

  provisioner "file" {
    content     = "role: edge"
    destination = "/etc/salt/grains"
  }

  provisioner "remote-exec" {
    inline = [
      "systemctl daemon-reload",
      "systemctl restart salt-minion",
    ]
  }
}

resource "null_resource" "salt-minion-etcd" {
  count = var.etcd_count

  connection {
    type                = "ssh"
    host                = element(var.etcd_private_ips, count.index)
    user                = var.ssh_user
    private_key         = file(var.ssh_private_key)
    agent               = false
    bastion_host        = var.bastion_host
    bastion_user        = var.ssh_user
    bastion_private_key = file(var.ssh_private_key)
  }

  provisioner "remote-exec" {
    script = "${path.module}/scripts/salt-minion.sh"
  }

  provisioner "file" {
    content     = element(data.template_file.master-conf.*.rendered, count.index)
    destination = "/etc/salt/minion.d/master.conf"
  }

  provisioner "file" {
    content     = "role: etcd"
    destination = "/etc/salt/grains"
  }

  provisioner "remote-exec" {
    inline = [
      "systemctl daemon-reload",
      "systemctl restart salt-minion",
    ]
  }
}

resource "null_resource" "salt-minion-master" {
  count = var.master_count

  connection {
    type                = "ssh"
    host                = element(var.master_private_ips, count.index)
    user                = var.ssh_user
    private_key         = file(var.ssh_private_key)
    agent               = false
    bastion_host        = var.bastion_host
    bastion_user        = var.ssh_user
    bastion_private_key = file(var.ssh_private_key)
  }

  provisioner "remote-exec" {
    script = "${path.module}/scripts/salt-minion.sh"
  }

  provisioner "file" {
    content     = element(data.template_file.master-conf.*.rendered, count.index)
    destination = "/etc/salt/minion.d/master.conf"
  }

  provisioner "file" {
    content     = "role: master"
    destination = "/etc/salt/grains"
  }

  provisioner "remote-exec" {
    inline = [
      "systemctl daemon-reload",
      "systemctl restart salt-minion",
    ]
  }
}

resource "null_resource" "salt-minion-node" {
  count = var.node_count

  connection {
    type                = "ssh"
    host                = element(var.node_private_ips, count.index)
    user                = var.ssh_user
    private_key         = file(var.ssh_private_key)
    agent               = false
    bastion_host        = var.bastion_host
    bastion_user        = var.ssh_user
    bastion_private_key = file(var.ssh_private_key)
    timeout             = "1m"
  }

  provisioner "remote-exec" {
    script = "${path.module}/scripts/salt-minion.sh"
  }

  provisioner "file" {
    content     = element(data.template_file.master-conf.*.rendered, count.index)
    destination = "/etc/salt/minion.d/master.conf"
  }

  provisioner "file" {
    content     = "role: node"
    destination = "/etc/salt/grains"
  }

  provisioner "remote-exec" {
    inline = [
      "systemctl daemon-reload",
      "systemctl restart salt-minion",
    ]
  }
}

data "template_file" "master-conf" {
  count    = var.master_count
  template = file("${path.module}/templates/master.conf")
  vars = {
    salt_master_host     = var.salt_master_host
  }
}