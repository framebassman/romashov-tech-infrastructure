output "instance_id" {
  description = "OCID of the compute instance"
  value       = oci_core_instance.this.id
}

output "instance_public_ip" {
  description = "Public IP of the primary VNIC (if assigned)"
  value       = oci_core_instance.this.public_ip
}

output "instance_private_ip" {
  description = "Private IP of the primary VNIC"
  value       = oci_core_instance.this.private_ip
}
