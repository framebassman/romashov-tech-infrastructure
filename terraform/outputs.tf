output "oci_vm_public_ip" {
  description = "Public IP для SSH на sweden-node"
  value       = module.oci_vm.instance_public_ip
}

# IP, с которого разрешён доступ к ocserv-exporter (порт 8000) на VPN-нодах.
# Используется в Ansible playbook vpn-firewall для iptables: allow только этот IP.
output "vpn_metrics_allowed_source_ip" {
  description = "IP Alloy (sweden-node) — единственный источник, которому на VPN-нодах разрешён доступ к :8000 (ocserv-exporter). Передавать в Ansible: -e vpn_metrics_allowed_source_ip=$(terraform output -raw vpn_metrics_allowed_source_ip)"
  value       = module.oci_vm.instance_public_ip
}
