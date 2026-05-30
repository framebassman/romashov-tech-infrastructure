# Существующая VCN vcn-20250808-1700 — создаём в ней подсеть
data "oci_core_vcns" "default" {
  compartment_id = local.compartment_id
  display_name   = "vcn-20250808-1700"
}

resource "oci_core_subnet" "default_vcn" {
  compartment_id             = local.compartment_id
  vcn_id                     = data.oci_core_vcns.default.virtual_networks[0].id
  cidr_block                 = "10.0.0.0/24"
  display_name               = "default-vcn-subnet"
  dns_label                  = "defaultsub"
  prohibit_public_ip_on_vnic = false
}

# Hosts the OTLP/HTTP receiver port (4318) for Grafana Alloy. Ingress is
# restricted to node2 (RU) — the only client that pushes traces. Subnet's
# default security list still only allows :22 + ICMP; NSG UNIONs with it.
resource "oci_core_network_security_group" "sweden_inbound" {
  compartment_id = local.compartment_id
  vcn_id         = data.oci_core_vcns.default.virtual_networks[0].id
  display_name   = "sweden-inbound"
}

# node2.romashov.tech (RU edge running Traefik) -> Alloy OTLP receiver.
resource "oci_core_network_security_group_security_rule" "sweden_inbound_otlp_http_from_node2" {
  network_security_group_id = oci_core_network_security_group.sweden_inbound.id
  direction                 = "INGRESS"
  protocol                  = "6" # TCP
  source                    = "109.172.90.19/32"
  source_type               = "CIDR_BLOCK"
  description               = "OTLP/HTTP from node2 Traefik tracing"

  tcp_options {
    destination_port_range {
      min = 4318
      max = 4318
    }
  }
}

# Vault on sweden1 listens plain HTTP; Cloudflare fronts vault.romashov.tech
# (proxied=true) and connects to the origin over HTTP in SSL mode "Flexible".
# Client-facing TLS terminates at CF's edge with the Universal cert.
# Trade-off: the CF→origin leg is plaintext over the public internet;
# acceptable here because this Vault is a backup secret store (primary is
# Cloudflare KV) and Vault's own auth is the real access control regardless.
resource "oci_core_network_security_group_security_rule" "sweden_inbound_http_vault" {
  network_security_group_id = oci_core_network_security_group.sweden_inbound.id
  direction                 = "INGRESS"
  protocol                  = "6" # TCP
  source                    = "0.0.0.0/0"
  source_type               = "CIDR_BLOCK"
  description               = "HTTP for Vault (Cloudflare-fronted, Flexible SSL mode)"

  tcp_options {
    destination_port_range {
      min = 80
      max = 80
    }
  }
}
