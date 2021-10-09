terraform {

  backend "remote" {
    organization = "mitsumaui"
    workspaces {
      name = "cf-dns"
    }
  }
}

module "migadu" {
  source = "./modules/migadu-mx-dns"

  for_each = {for cfdomain in jsondecode(var.domainlist).domainlist: cfdomain.domain => cfdomain}

  domain = each.value.domain
  verify = each.value.verify
}