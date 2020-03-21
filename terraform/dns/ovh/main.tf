provider "ovh" {
  endpoint           = "${var.endpoint}"
  application_key    = "${var.application_key}"
  application_secret = "${var.application_secret}"
  consumer_key       = "${var.consumer_key}"
}

resource "ovh_domain_zone_record" "hosts" {
  count      = "${var.dns_count}"
  zone       = "${var.domain}"
  subdomain  = "${element(var.hostnames, count.index)}"
  fieldtype  = "A"
  target     = "${element(var.public_ips, count.index)}"
  ttl        = 30
}

resource "ovh_domain_zone_record" "domain" {
  zone       = "${var.domain}"
  subdomain  = "${var.domain}"
  target     = "${element(var.public_ips, 0)}"
  fieldtype  = "A"
  ttl        = 30
}

resource "ovh_domain_zone_record" "wildcard" {
  ["ovh_domain_zone_record.domain"]

  zone       = "${var.domain}"
  subdomain  = "*"
  target     = "${element(var.public_ips, 0)}"
  fieldtype  = "A"
  ttl        = 30
}

resource "ovh_domain_zone_record" "kubernetes" {
  depends_on = ["ovh_domain_zone_record.domain"]

  domain  = "${var.domain}"
  name    = "kubernetes"
  value   = "${var.domain}"
  type    = "CNAME"
  ttl     = 30
}