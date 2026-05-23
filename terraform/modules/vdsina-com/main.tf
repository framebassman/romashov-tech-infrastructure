# SSH keys — data field not returned by API after creation; ignore_changes prevents drift
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

resource "vdsina_ssh_key" "pixel" {
  name = "pixel"
  data = ""
  lifecycle { ignore_changes = [data] }
}

resource "vdsina_ssh_key" "pixel_biometric" {
  name = "pixel-biometric"
  data = ""
  lifecycle { ignore_changes = [data] }
}

# Servers — template is immutable after creation; ssh_key not tracked by API
resource "vdsina_server" "node1" {
  name        = "node1.romashov.tech"
  host        = "node1.romashov.tech"
  datacenter  = 1  # Amsterdam 2, Netherlands
  server_plan = 1  # 2 RAM / 1 CPU / 40 NVMe
  template    = 23 # Ubuntu 24.04
  ssh_key     = vdsina_ssh_key.romashov_komplukter.id
  lifecycle { ignore_changes = [host, template, ssh_key] }
}

resource "vdsina_server" "out_3x" {
  name        = "out.3x.romashov.tech"
  host        = "out.3x.romashov.tech"
  datacenter  = 1  # Amsterdam 2, Netherlands
  server_plan = 36 # 1 RAM / 1 CPU / 10 NVMe
  template    = 64 # Ubuntu 26.04
  ssh_key     = vdsina_ssh_key.romashov_komplukter.id
  lifecycle { ignore_changes = [host, template, ssh_key] }
}
