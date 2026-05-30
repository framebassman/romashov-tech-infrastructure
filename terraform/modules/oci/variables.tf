variable "tenancy_ocid" {
  description = "Tenancy OCID"
  type        = string
}

variable "group_name" {
  description = "IAM-группа, которой даём права (Console: Identity → Users → твой user → Groups)"
  type        = string
  default     = "Administrators"
}
