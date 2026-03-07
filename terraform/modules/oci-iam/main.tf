terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "~> 8"
    }
  }
}

# Политика: разрешить группе создавать VM и работать с сетью
resource "oci_identity_policy" "compute" {
  compartment_id = var.tenancy_ocid
  name           = "terraform-oci-vm-policy"
  description    = "Allow compute and network for Terraform OCI VM"
  statements = [
    "Allow group ${var.group_name} to manage instance-family in tenancy",
    "Allow group ${var.group_name} to manage virtual-network-family in tenancy",
    "Allow group ${var.group_name} to manage volume-family in tenancy",
  ]
}
