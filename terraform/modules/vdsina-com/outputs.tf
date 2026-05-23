output "node1_public_ip" {
  description = "Public IP of node1.romashov.tech"
  value       = vdsina_server.node1.ip
}

output "out_3x_public_ip" {
  description = "Public IP of out.3x.romashov.tech"
  value       = vdsina_server.out_3x.ip
}
