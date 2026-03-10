output "oci_vm_public_ip" {
  description = "Public IP для SSH на sweden-node"
  value       = module.oci_vm.instance_public_ip
}

output "vpn_metrics_allowed_source_ip" {
  description = "Public IP sweden-node (Alloy). Раньше использовался для UFW на VPN-нодах; сейчас метрики защищены секретным путём в URL."
  value       = module.oci_vm.instance_public_ip
}
