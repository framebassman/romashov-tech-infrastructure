resource "cloudflare_pages_project" "romashov_tech_web" {
  account_id        = var.account_id
  name              = "romashov-tech-web"
  production_branch = "master"

  # GitHub integration, env vars, and build config are managed outside TF
  lifecycle { ignore_changes = [source, build_config, deployment_configs] }
}

resource "cloudflare_pages_project" "romashov_tech_status" {
  account_id        = var.account_id
  name              = "romashov-tech-status"
  production_branch = "master"

  lifecycle { ignore_changes = [source, build_config, deployment_configs] }
}
