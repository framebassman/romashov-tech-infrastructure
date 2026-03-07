terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "~> 8"
    }
  }
}

locals {
  compartment_id             = "ocid1.tenancy.oc1..aaaaaaaamw5qcdprotjyd7tjbxuijfmjpdxndosth5wiul6ag2m54wqhnzna"
  instance_shape             = "VM.Standard.E2.1.Micro"
  shape_config_ocpus         = null
  shape_config_memory_in_gbs = null
  availability_domain_index  = 0
  instance_display_name      = "sweden-node"
  assign_public_ip           = true
}

data "oci_identity_availability_domains" "ads" {
  compartment_id = local.compartment_id
}

data "oci_core_images" "ubuntu" {
  compartment_id           = local.compartment_id
  operating_system         = "Canonical Ubuntu"
  operating_system_version = "22.04"
  shape                    = local.instance_shape
}

resource "oci_core_instance" "this" {
  compartment_id      = local.compartment_id
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[local.availability_domain_index].name
  display_name        = local.instance_display_name
  shape               = local.instance_shape

  dynamic "shape_config" {
    for_each = local.shape_config_ocpus != null && local.shape_config_memory_in_gbs != null ? [1] : []
    content {
      ocpus         = local.shape_config_ocpus
      memory_in_gbs = local.shape_config_memory_in_gbs
    }
  }

  create_vnic_details {
    subnet_id              = var.subnet_id
    assign_public_ip       = local.assign_public_ip
    hostname_label         = local.instance_display_name
    skip_source_dest_check = false
  }

  source_details {
    source_type = "image"
    source_id   = data.oci_core_images.ubuntu.images[0].id
  }

  # После import не менять образ существующей VM (subnet не игнорируем — нужна замена при смене VCN)
  lifecycle {
    ignore_changes = [source_details]
  }
}
