variable "dns_count" {}

variable "endpoint" {
  default = "ovh-eu"
}

variable "application_key" {}

variable "application_secret" {}

variable "consumer_key" {}

variable "domain" {}

variable "hostnames" {
  type = "list"
}

variable "public_ips" {
  type = "list"
}