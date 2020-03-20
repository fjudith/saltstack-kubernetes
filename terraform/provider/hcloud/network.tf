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