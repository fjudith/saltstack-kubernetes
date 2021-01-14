provider "cloudflare" {
  email = var.email
  api_key = var.token
}

resource "cloudflare_record" "hosts" {
  count = var.dns_count

  zone_id = var.zone_id
  name    = element(var.hostnames, count.index)
  value   = element(var.public_ips, count.index)
  type    = "A"
  proxied = false
}

resource "cloudflare_record" "domain" {
  zone_id = var.zone_id
  name    = var.domain
  value   = element(var.public_ips, 0)
  type    = "A"
  proxied = true
}

resource "cloudflare_record" "wildcard" {
  depends_on = [cloudflare_record.domain]

  zone_id = var.zone_id
  name    = "*"
  value   = element(var.public_ips, 0)
  type    = "A"
  proxied = false
}

resource "cloudflare_record" "kubernetes" {
  depends_on = [cloudflare_record.domain]

  zone_id = var.zone_id
  name    = "kubernetes"
  value   = var.domain
  type    = "CNAME"
  proxied = false
}