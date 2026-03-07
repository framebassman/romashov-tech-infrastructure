output "oci_vm_public_ip" {
  description = "Public IP для SSH на sweden-node"
  value       = module.oci_vm.instance_public_ip
}
