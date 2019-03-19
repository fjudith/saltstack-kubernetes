output "domains" {
  value = ["${cloudflare_record.hosts.*.hostname}"]
}