terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5.17"
    }
    external = {
      source  = "hashicorp/external"
      version = "~> 2"
    }
  }
}


