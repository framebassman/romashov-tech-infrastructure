terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "~> 8"
    }
  }
}

resource "oci_core_vcn" "main" {
  compartment_id = var.compartment_id
  cidr_blocks    = ["10.0.0.0/16"]
  display_name   = "terraform-vcn"
  dns_label      = "tfvcn"
}

resource "oci_core_subnet" "main" {
  compartment_id             = var.compartment_id
  vcn_id                     = oci_core_vcn.main.id
  cidr_block                 = "10.0.0.0/24"
  display_name               = "terraform-subnet"
  dns_label                  = "tfsubnet"
  prohibit_public_ip_on_vnic = false
}
