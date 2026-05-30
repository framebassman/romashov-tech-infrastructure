variable "project_name" {
  description = "Aiven console project name"
  type        = string
}

# OCI (аутентификация через переменные в terraform.tfvars / backend.conf)
variable "oci_tenancy_ocid" {
  description = "OCI tenancy OCID"
  type        = string
  default     = "ocid1.tenancy.oc1..aaaaaaaamw5qcdprotjyd7tjbxuijfmjpdxndosth5wiul6ag2m54wqhnzna"
}

variable "oci_user_ocid" {
  description = "OCI user OCID (идентификатор, не секрет)"
  type        = string
  default     = "ocid1.user.oc1..aaaaaaaadoufvv6oqe2dmjo4lxx455mpspm74sd6syz4o5bsznhs76edpd3a"
}

variable "oci_fingerprint" {
  description = "Fingerprint of the OCI API key (идентификатор ключа, не секрет)"
  type        = string
  default     = "e9:16:a2:8f:7b:7f:ef:29:a8:4d:f8:c5:a3:1f:be:c0"
}

variable "oci_private_key" {
  description = "OCI API private key PEM file"
  type        = string
  sensitive   = true
}

# Grafana Cloud — used by modules/grafana-monitoring
variable "grafana_stack_slug" {
  description = "Grafana Cloud stack slug (the <slug>.grafana.net subdomain)"
  type        = string
  default     = "romashovtech"
}

