variable "compartment_id" {
  description = "OCI compartment OCID"
  type        = string
  default = "ocid1.instance.oc1.eu-stockholm-1.anqxeljryneafxycu45rfs7efir6uaw6cmpydknxiw25ph35fil254kkejgq"
}

variable "instance_shape" {
  description = "Compute instance shape"
  type        = string
  default     = "VM.Standard.E2.1.Micro"
}

variable "instance_image_id" {
  description = "Image OCID for the instance. If empty, uses first Oracle Linux 9 image in the compartment."
  type        = string
  default     = "ocid1.image.oc1.eu-stockholm-1.aaaaaaaadulzjnjqv3asataknqp2qprwpuv2cg3qvyijrqxkpu5eur76mnca"
}
