provider "scaleway" {
  organization = "${var.organization}"
  token        = "${var.token}"
  region       = "${var.region}"
  version      = "~> 1.4"
}

data "scaleway_image" "ubuntu" {
  architecture = "${var.architecture}"
  name         = "${var.image}"
}

data "scaleway_bootscript" "bootscript" {
  architecture = "${var.architecture}"
  name_filter  = "mainline 4.15.11 rev1"
}

resource "scaleway_ip" "public_ip" {
  count = "${var.etcd_count}"
}