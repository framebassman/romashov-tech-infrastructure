variable "account_id" {
  description = "Cloudflare account ID"
  type        = string
}

variable "alloy_public_ip" {
  description = "Public IPv4 of the sweden-node VM. Sourced from module.oci_vm.instance_public_ip so a_alloy survives VM recreation without manual DNS edits."
  type        = string
}
