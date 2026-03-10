output "oci_vm_public_ip" {
  description = "Public IP для SSH на sweden-node"
  value       = module.oci_vm.instance_public_ip
}

output "vpn_metrics_allowed_source_ip" {
  description = "Public IP sweden-node (Alloy)."
  value       = module.oci_vm.instance_public_ip
}
