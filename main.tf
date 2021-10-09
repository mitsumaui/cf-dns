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

output "domainlist" {
  value = jsondecode(var.domainlist)
}

module "migadu" {
  source = "./modules/migadu-mx-dns"

  for_each = {for cfdomain in jsondecode(var.domainlist).domainlist: cfdomain.domain => cfdomain}
  
  # domain = var.domain
  # verify = var.verify
  domain = each.value.domain
  verify = each.value.verify
}