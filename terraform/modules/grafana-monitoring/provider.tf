terraform {
  required_version = ">=1.14"
  required_providers {
    grafana = {
      source  = "grafana/grafana"
      version = "~> 4.29"
    }
  }
}
