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

resource "hcloud_server" "proxy01" {
  count       = 1
  name        = "proxy01"
  location    = "${var.location}"
  image       = "${var.image}"
  server_type = "${var.proxy_type}"
  ssh_keys    = ["${var.ssh_keys}"]
  user_data   = "${file("${format("%s/templates/proxy_user-data.yaml", path.module)}")}"
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
      "while [ ! -f /var/lib/cloud/instance/boot-finished ]; do echo 'waiting for boot-finished'; sleep 5; done;",
      "while [ ! -f /var/lib/apt/lists/lock ]; do sleep 1; done",
      "while [ ! -f /var/lib/dpkg/lock ]; do sleep 1; done",
      "while fuser /var/lib/apt/lists/lock >/dev/null 2>&1; do sleep 1; done",
      "while fuser /var/lib/dpkg/lock >/dev/null 2>&1; do sleep 1; done",
      "while fuser /var/lib/dpkg/lock-frontend >/dev/null 2>&1; do sleep 1; done",
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
# proxy02
##################################################
resource "hcloud_server" "proxy02" {
  depends_on = ["hcloud_server.proxy01"]

  count       = 1
  name        = "proxy02"
  location    = "${var.location}"
  image       = "${var.image}"
  server_type = "${var.proxy_type}"
  ssh_keys    = ["${var.ssh_keys}"]
  user_data   = "${file("${format("%s/templates/proxy_user-data.yaml", path.module)}")}"
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
    bastion_host        = "${hcloud_server.proxy01.0.ipv4_address}"
    bastion_user        = "${var.ssh_user}"
    bastion_private_key = "${file(var.ssh_private_key)}"
    timeout             = "2m"
  }

  provisioner "remote-exec" {
    inline = [
      "while [ ! -f /var/lib/cloud/instance/boot-finished ]; do echo 'waiting for boot-finished'; sleep 5; done;",
      "while [ ! -f /var/lib/apt/lists/lock ]; do sleep 1; done",
      "while [ ! -f /var/lib/dpkg/lock ]; do sleep 1; done",
      "while fuser /var/lib/apt/lists/lock >/dev/null 2>&1; do sleep 1; done",
      "while fuser /var/lib/dpkg/lock >/dev/null 2>&1; do sleep 1; done",
      "while fuser /var/lib/dpkg/lock-frontend >/dev/null 2>&1; do sleep 1; done",
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
  depends_on = ["hcloud_server.proxy01"]

  count       = "${var.etcd_count}"
  name        = "${format("etcd%02d", count.index + 1)}"
  location    = "${var.location}"
  image       = "${var.image}"
  server_type = "${var.etcd_type}"
  ssh_keys    = ["${var.ssh_keys}"]
  user_data   = "${file("${format("%s/templates/etcd_user-data.yaml", path.module)}")}"
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
    bastion_host        = "${hcloud_server.proxy01.0.ipv4_address}"
    bastion_user        = "${var.ssh_user}"
    bastion_private_key = "${file(var.ssh_private_key)}"
    timeout             = "2m"
  }

  provisioner "remote-exec" {
    inline = [
      "while [ ! -f /var/lib/cloud/instance/boot-finished ]; do echo 'waiting for boot-finished'; sleep 5; done;",
      "while [ ! -f /var/lib/apt/lists/lock ]; do sleep 1; done",
      "while [ ! -f /var/lib/dpkg/lock ]; do sleep 1; done",
      "while fuser /var/lib/apt/lists/lock >/dev/null 2>&1; do sleep 1; done",
      "while fuser /var/lib/dpkg/lock >/dev/null 2>&1; do sleep 1; done",
      "while fuser /var/lib/dpkg/lock-frontend >/dev/null 2>&1; do sleep 1; done",
    ]
  }
}

##################################################
# Kubernetes Master
##################################################
resource "hcloud_server" "master" {
  depends_on = ["hcloud_server.proxy01", "hcloud_server.etcd"]

  count       = "${var.master_count}"
  name        = "${format("master%02d", count.index + 1)}"
  location    = "${var.location}"
  image       = "${var.image}"
  server_type = "${var.master_type}"
  ssh_keys    = ["${var.ssh_keys}"]
  user_data   = "${file("${format("%s/templates/master_user-data.yaml", path.module)}")}"
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
    bastion_host        = "${hcloud_server.proxy01.0.ipv4_address}"
    bastion_user        = "${var.ssh_user}"
    bastion_private_key = "${file(var.ssh_private_key)}"
    timeout             = "2m"
  }

  provisioner "remote-exec" {
    inline = [
      "while [ ! -f /var/lib/cloud/instance/boot-finished ]; do echo 'waiting for boot-finished'; sleep 5; done;",
      "while [ ! -f /var/lib/apt/lists/lock ]; do sleep 1; done",
      "while [ ! -f /var/lib/dpkg/lock ]; do sleep 1; done",
      "while fuser /var/lib/apt/lists/lock >/dev/null 2>&1; do sleep 1; done",
      "while fuser /var/lib/dpkg/lock >/dev/null 2>&1; do sleep 1; done",
      "while fuser /var/lib/dpkg/lock-frontend >/dev/null 2>&1; do sleep 1; done",
    ]
  }
}

##################################################
# Kubernetes Node
##################################################
resource "hcloud_server" "node" {
  depends_on = ["hcloud_server.proxy01", "hcloud_server.master"]

  count       = "${var.node_count}"
  name        = "${format("node%02d", count.index + 1)}"
  location    = "${var.location}"
  image       = "${var.image}"
  server_type = "${var.node_type}"
  ssh_keys    = ["${var.ssh_keys}"]
  user_data   = "${file("${format("%s/templates/node_user-data.yaml", path.module)}")}"
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
    bastion_host        = "${hcloud_server.proxy01.0.ipv4_address}"
    bastion_user        = "${var.ssh_user}"
    bastion_private_key = "${file(var.ssh_private_key)}"
    timeout             = "2m"
  }

  provisioner "remote-exec" {
    inline = [
      "while [ ! -f /var/lib/cloud/instance/boot-finished ]; do echo 'waiting for boot-finished'; sleep 5; done;",
      "while [ ! -f /var/lib/apt/lists/lock ]; do sleep 1; done",
      "while [ ! -f /var/lib/dpkg/lock ]; do sleep 1; done",
      "while fuser /var/lib/apt/lists/lock >/dev/null 2>&1; do sleep 1; done",
      "while fuser /var/lib/dpkg/lock >/dev/null 2>&1; do sleep 1; done",
      "while fuser /var/lib/dpkg/lock-frontend >/dev/null 2>&1; do sleep 1; done",
    ]
  }
}

resource "hcloud_server_network" "proxy01" {
  count = 1
  server_id = "${hcloud_server.proxy01.id}"
  network_id = "${hcloud_network.private.id}"
}

resource "hcloud_server_network" "proxy02" {
  count = 1
  server_id = "${hcloud_server.proxy02.id}"
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