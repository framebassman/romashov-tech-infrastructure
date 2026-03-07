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

  metadata = {
    "ssh_authorized_keys" = <<-EOT
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDWfzN8ganx0700nCWVhJb+afH7SpRkjknelNXIXoNeWpbz2kURcx4Lq75RJ97innttyyhMf4y0qZZ/qe1Y2QGecmX+GI1BUfpcq0ZCc8u9xxcbEprEtVX+JOisZHljcEjEy/1LzqHEhNX+8w7tQLtCjf7EjSZdzucm1l2JWl7j2A3XJTROcNeW8EFZSBY6f5VLWF4QCkdI3pTRXuv83iJyJ66THQeh4U3uvVivaV/Y0HG08tq/uTxcbmlcfK/vHiQVg3igxgz656K/wi431REObNV/JFozJ+khNbXalP0xHoYHME/agBBxBDlak2awHgk47jlMhisy5cuh+FZk7Re8x8rv9XLZnbszIF6NMAYaPZe7qp6+CInZYz2xdUDAKFmCv4/A33c1z8ac/cfky11jtzjMY3uCTP+UouwxvsONX6SSOPt4iEAKpEsOYdwxPRnGuh6rzxNPt70U5t2gKCobVGvX/l8nLjwn9QCnWP/XHuDTeYmzDQrzdjyau0DD5R8= d.romashov@komplukter
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGVPbc6+NsvLcS5PKrXmlCKLb8JOC5gtydWuNgbtljcY
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCtkA9a4oazfcrGZTACUrYC65vJY5gPm0igHRBm6/0QGrAsO1drXkSNY5/ZSDnM736qoj4/ZNNRD6P94N3vgRKM/gWvd5nYqCX4tWf87huhcHY3+F6c0ChKlZ+lIj6gnsZFmYh47Wv5EvGb0sRUnYgW9lg9sHoQNkd4R5R6y2tZjmLOLiaCJD+/xdrVqXxxLLNJzAaJtAd6Sv7E3pCOtJ/v0CgER4nmsX/I/U7THh4Inchmn7CD/DYX5oHuEyJLGFnXeJdAcOLkJ1A9uv3Md9gQHp00N6bYl/4jMzhcP57DpawMGRQO6xB0+AiC9W/uVl5PNhNONasNZrZYMVOP1sywKvuj1o5wpoHlIakJx5DF9b7/SRRQQWzuveMkK/K3+NdsjIG11651X48gGh6rRJ9pphxGzYNQyR9fIaZPS1t9rrv1pkypmyc25AErw+/8m3qw8NLdk4sbnW+IBWG2Odm2bKdnhQFpJhOsycIRUh1EvWbILtnftjIzo1/7FsipUBs= d.romashov@workstation-Vostro-15-3510
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCmNrm+XpULNaQdhgXNbI82riDJ/yjLHmlPN055m7K9RC7+yOyFWFni8Nov9Vz/E/rNrg7+F6rN4gnr4tPteWamDuORmcDVfmpc5bETjlmvjfNTof3lCRhhOcxyiI0OsYEX0Qrlr11rWxpkDEAdIRorzBrlwwWBoYK4sYMLPe9xbyNG7fKzkuvCSpxFSYvGdRuayl/KGGRPHTkDnhrfDW9Lf8VDdSYp8fdgiI6UMcaWT7r9XIj71XxE+b27OvC57xTAe4YgWQ1z+G5xTtDLC9jueXoDtjvR1say1KpTpw9mzyUZifdiSlFf5Kro2Ig0NpZJeh3Flvs+Y0FrhNJAV9qbOIBX0VLyixvWUGkZNIZjsfIxkQdec+xYHVs2BQqF+wqCsfUNaC/YqJtVDcVuhasA4dy8xTVOKEqH5DFpn8sFZi9gNbOwcmXjTT9WQ4ij9Q86xFoPhITIammjfm1cXLGD7iTnyarRaw4t5U47e1o0++cQFL6WLqEYaeJzOvWaMb8= github@komplukter
EOT
  }

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
