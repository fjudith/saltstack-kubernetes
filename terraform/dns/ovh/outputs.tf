output "domains" {
  value = ovh_domain_zone_record.hosts.*.target
}