terraform {
  required_providers {
    vdsina = {
      source  = "scinfra-pro/vdsina"
      version = "~> 0.2"
    }
  }
}

provider "vdsina" {
  api_token = var.vdsina_api_token
  base_url  = "https://userapi.vdsina.ru/v1"
}
