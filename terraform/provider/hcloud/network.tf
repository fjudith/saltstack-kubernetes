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