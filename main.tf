terraform {

  backend "remote" {
    organization = "mitsumaui"
    workspaces {
      name = "cf-dns"
    }
  }

#   required_providers {
#     cloudflare = {
#       source  = "cloudflare/cloudflare"
#       version = "3.1.0"
#     }
#     http = {
#       source  = "hashicorp/http"
#       version = "2.1.0"
#     }
#   }
}

module "migadu" {
    source = "./modules/migadu-mx-dns"
    
    domain = var.domain
    verify = var.verify
}