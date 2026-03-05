# Данные для подстановки (AD и образ), если image_id не задан
data "oci_identity_availability_domains" "ads" {
  compartment_id = var.compartment_id
}

data "oci_core_images" "oracle_linux" {
  compartment_id           = var.compartment_id
  operating_system         = "Oracle Linux"
  operating_system_version = "9"
  shape                    = var.instance_shape
}

resource "oci_core_instance" "this" {
  compartment_id      = var.compartment_id
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  shape               = var.instance_shape

  source_details {
    source_type = "image"
    source_id   = var.instance_image_id
  }

  # После import не менять образ и VNIC существующей VM
  lifecycle {
    ignore_changes = [
      source_details,
      create_vnic_details
    ]
  }
}
