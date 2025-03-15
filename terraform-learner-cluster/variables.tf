# Set to true if you're making use of ExternalDNS with Route53
variable "enable_external_dns" {
  type    = bool
  default = true
}

# Set to true if you're making use of Loki with a s3 backend
variable "enable_loki_s3" {
  type    = bool
  default = true
}
