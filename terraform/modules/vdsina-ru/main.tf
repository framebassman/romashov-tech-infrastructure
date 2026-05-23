# SSH keys — data field not returned by API after creation; ignore_changes prevents drift
resource "vdsina_ssh_key" "all_together" {
  name = "all-together"
  data = ""
  lifecycle { ignore_changes = [data] }
}

resource "vdsina_ssh_key" "romashov_komplukter" {
  name = "d.romashov@komplukter"
  data = ""
  lifecycle { ignore_changes = [data] }
}

resource "vdsina_ssh_key" "romashov_workstation" {
  name = "d.romashov@workstation-Vostro-15-3510"
  data = ""
  lifecycle { ignore_changes = [data] }
}

resource "vdsina_ssh_key" "github_komplukter" {
  name = "github@komplukter"
  data = ""
  lifecycle { ignore_changes = [data] }
}

# Servers — template is immutable after creation; ssh_key not tracked by API
resource "vdsina_server" "node2" {
  name        = "node2.romashov.tech"
  host        = "node2.romashov.tech"
  datacenter  = 3   # Moscow, Russia
  server_plan = 154 # 1 RAM / 1 CPU / 10 NVMe
  template    = 48  # Ubuntu 24.04
  ssh_key     = vdsina_ssh_key.all_together.id
  lifecycle { ignore_changes = [host, template, ssh_key] }
}
