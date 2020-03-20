##################################################
# proxy01
##################################################
resource "hcloud_network" "private" {
  name = "private"
  ip_range = "10.0.0.0/8"
  labels = {
    app = "kubernetes"
  }
}

resource "hcloud_network_subnet" "kubernetes" {
  network_id = "${hcloud_network.private.id}"
  type = "server"
  network_zone = "eu-central"
  ip_range = "10.0.1.0/24"
}

resource "hcloud_server" "edge01" {
  count       = 1
  name        = "edge01"
  location    = "${var.location}"
  image       = "${var.image}"
  server_type = "${var.edge_type}"
  ssh_keys    = ["${var.ssh_keys}"]
  user_data   = "${data.template_file.edge01_cloud-init.rendered}"
  labels = {
    app  = "kubernetes"
    role = "edge_router"
    salt = "master"
  }

  connection {
    type        = "ssh"
    host        = "${self.ipv4_address}"
    user        = "${var.ssh_user}"
    private_key = "${file(var.ssh_private_key)}"
    agent       = false
    timeout     = "1m"
  }

  provisioner "remote-exec" {
    inline = [
      "cloud-init status --long --wait",
    ]
  }

  # provisioner "remote-exec" {
  #   inline = [
  #     "echo 'http_proxy=http://localhost:3128' | tee -a  /etc/environment",
  #     "echo 'https_proxy=http://localhost:3128' | tee -a  /etc/environment",
  #   ]
  # }

  provisioner "file" {
    content     = "${file(var.ssh_private_key)}"
    destination = "~/.ssh/id_rsa"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod 400 ~/.ssh/id_rsa",
    ]
  }

  provisioner "file" {
    content     = "${file(var.ssh_public_key)}"
    destination = "~/.ssh/id_rsa.pub"
  }
}

##################################################
# edge02
##################################################
resource "hcloud_server" "edge02" {
  depends_on = ["hcloud_server.edge01"]

  count       = 1
  name        = "edge02"
  location    = "${var.location}"
  image       = "${var.image}"
  server_type = "${var.edge_type}"
  ssh_keys    = ["${var.ssh_keys}"]
  user_data   = "${data.template_file.edge02_cloud-init.rendered}"
  labels = {
    app  = "kubernetes"
    role = "edge_router"
    salt = "master"
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

  # provisioner "remote-exec" {
  #   inline = [
  #     "echo 'http_proxy=http://localhost:3128' | tee -a  /etc/environment",
  #     "echo 'https_proxy=http://localhost:3128' | tee -a  /etc/environment",
  #   ]
  # }

  provisioner "file" {
    content     = "${file(var.ssh_private_key)}"
    destination = "~/.ssh/id_rsa"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod 400 ~/.ssh/id_rsa",
    ]
  }

  provisioner "file" {
    content     = "${file(var.ssh_public_key)}"
    destination = "~/.ssh/id_rsa.pub"
  }
}

##################################################
# etcd
##################################################
resource "hcloud_server" "etcd" {
  depends_on = ["hcloud_server.edge01"]

  count       = "${var.etcd_count}"
  name        = "${format("etcd%02d", count.index + 1)}"
  location    = "${var.location}"
  image       = "${var.image}"
  server_type = "${var.etcd_type}"
  ssh_keys    = ["${var.ssh_keys}"]
  user_data   = "${data.template_file.etcd_cloud-init.rendered}"
  labels = {
    app  = "kubernetes"
    role = "etcd"
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

##################################################
# Kubernetes Master
##################################################
resource "hcloud_server" "master" {
  depends_on = ["hcloud_server.edge01", "hcloud_server.etcd"]

  count       = "${var.master_count}"
  name        = "${format("master%02d", count.index + 1)}"
  location    = "${var.location}"
  image       = "${var.image}"
  server_type = "${var.master_type}"
  ssh_keys    = ["${var.ssh_keys}"]
  user_data   = "${data.template_file.master_cloud-init.rendered}"
  labels = {
    app  = "kubernetes"
    role = "master"
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