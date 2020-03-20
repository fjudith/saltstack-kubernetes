##################################################
# Kubernetes Node
##################################################
resource "hcloud_server" "node" {
  depends_on = ["hcloud_server.edge01", "hcloud_server.master"]

  count       = "${var.node_count}"
  name        = "${format("node%02d", count.index + 1)}"
  location    = "${var.location}"
  image       = "${var.image}"
  server_type = "${var.node_type}"
  ssh_keys    = ["${var.ssh_keys}"]
  user_data   = "${data.template_file.node_cloud-init.rendered}"
  labels = {
    app  = "kubernetes"
    role = "node"
    salt = "minion"
  }

  connection {
    type                = "ssh"
    host                = "${self.ipv4_address}"
    user                = "${var.ssh_user}"
    private_key         = "${file(var.ssh_private_key)}"
    agent               = false
    bastion_host        = "${hcloud_server.edge01.0.ipv4_address}"
    bastion_user        = "${var.ssh_user}"
    bastion_private_key = "${file(var.ssh_private_key)}"
    timeout             = "2m"
  }

  provisioner "remote-exec" {
    inline = [
      "cloud-init status --long --wait",
    ]
  }
}

resource "hcloud_server_network" "edge01" {
  count = 1
  server_id = "${hcloud_server.edge01.id}"
  network_id = "${hcloud_network.private.id}"
}

resource "hcloud_server_network" "edge02" {
  count = 1
  server_id = "${hcloud_server.edge02.id}"
  network_id = "${hcloud_network.private.id}"
}

resource "hcloud_server_network" "etcd" {
  count = "${var.etcd_count}"
  server_id = "${element(hcloud_server.etcd.*.id, count.index)}"
  network_id = "${hcloud_network.private.id}"
}

resource "hcloud_server_network" "master" {
  count = "${var.master_count}"
  server_id = "${element(hcloud_server.master.*.id, count.index)}"
  network_id = "${hcloud_network.private.id}"
}

resource "hcloud_server_network" "node" {
  count = "${var.node_count}"
  server_id = "${element(hcloud_server.node.*.id, count.index)}"
  network_id = "${hcloud_network.private.id}"
}

data "template_file" "edge01_cloud-init" {
  template = "${file("${path.module}/templates/edge_user-data.yaml")}"
  vars {
    SALT_MASTER_HOST     = "localhost"
    VPN_INTERFACE        = "${var.vpn_interface}"
    VPN_IP_RANGE         = "${var.vpn_iprange}"
    VPN_PORT             = "${var.vpn_port}"
    PRIVATE_INTERFACE    = "eth0"
  }
}

data "template_file" "edge02_cloud-init" {
  template = "${file("${path.module}/templates/edge_user-data.yaml")}"
  vars {
    SALT_MASTER_HOST     = "${hcloud_server.edge01.0.name}"
    VPN_INTERFACE        = "${var.vpn_interface}"
    VPN_IP_RANGE         = "${var.vpn_iprange}"
    VPN_PORT             = "${var.vpn_port}"
    PRIVATE_INTERFACE    = "eth0"
  }
}

data "template_file" "etcd_cloud-init" {
  count    = 1
  template = "${file("${path.module}/templates/etcd_user-data.yaml")}"
  vars {
    SALT_MASTER_HOST     = "${hcloud_server.edge01.0.name}"
    VPN_INTERFACE        = "${var.vpn_interface}"
    VPN_IP_RANGE         = "${var.vpn_iprange}"
    VPN_PORT             = "${var.vpn_port}"
    PRIVATE_INTERFACE    = "eth0"
  }
}

data "template_file" "master_cloud-init" {
  count    = 1
  template = "${file("${path.module}/templates/master_user-data.yaml")}"
  vars {
    SALT_MASTER_HOST     = "${hcloud_server.edge01.0.name}"
    VPN_INTERFACE        = "${var.vpn_interface}"
    VPN_IP_RANGE         = "${var.vpn_iprange}"
    VPN_PORT             = "${var.vpn_port}"
    PRIVATE_INTERFACE    = "eth0"
  }
}

data "template_file" "node_cloud-init" {
  count    = 1
  template = "${file("${path.module}/templates/node_user-data.yaml")}"
  vars {
    SALT_MASTER_HOST     = "${hcloud_server.edge01.0.name}"
    VPN_INTERFACE        = "${var.vpn_interface}"
    VPN_IP_RANGE         = "${var.vpn_iprange}"
    VPN_PORT             = "${var.vpn_port}"
    PRIVATE_INTERFACE    = "eth0"
  }
}