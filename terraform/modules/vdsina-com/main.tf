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

resource "vdsina_ssh_key" "pixel-biometric" {
  name = "pixel-biometric"
  data = ""
  lifecycle { ignore_changes = [data] }
}

# Servers — template is immutable after creation; ssh_key not tracked by API
resource "vdsina_server" "out_3x_romashov_tech" {
  name        = "out_3x_romashov_tech"
  host        = "out.3x.romashov.tech"
  datacenter  = 1   # Netherlands — verify after import via: curl -H "Authorization: <token>" https://userapi.vdsina.com/v1/datacenter
  server_plan = 154 # 1 RAM / 1 CPU / 10 NVMe — verify after import via: curl ... /server-plan
  template    = 48  # Ubuntu 24.04
  ssh_key     = vdsina_ssh_key.romashov_workstation.id
  lifecycle { ignore_changes = [host, template, ssh_key] }
}
