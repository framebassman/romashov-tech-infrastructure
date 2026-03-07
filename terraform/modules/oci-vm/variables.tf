# Все параметры VM захардкожены; subnet_id передаётся из корня (ресурс oci_core_subnet.default_vcn)
variable "subnet_id" {
  description = "OCID подсети (из корня: oci_core_subnet.default_vcn.id)"
  type        = string
}
