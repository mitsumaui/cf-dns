terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "3.1.0"
    }
  }
}

data "cloudflare_zones" "domain" {
  filter {
    name = var.domain
  }
}

resource "cloudflare_record" "txt_verify" {
  name    = var.domain
  zone_id = lookup(data.cloudflare_zones.domain.zones[0], "id")
  value   = "hosted-email-verify=${var.verify}"
  proxied = false
  type    = "TXT"
  ttl     = 1
}

resource "cloudflare_record" "mx" {
  count = 2

  name    = var.domain
  zone_id = lookup(data.cloudflare_zones.domain.zones[0], "id")
  value   = "aspmx${count.index + 1}.migadu.com"
  proxied = false
  type    = "MX"
  ttl     = 1
  priority = (count.index  + 1) * 10
}

resource "cloudflare_record" "mx_wildcard" {
  count = var.mx_wildcard == true ? 2 : 0

  name    = "*"
  zone_id = lookup(data.cloudflare_zones.domain.zones[0], "id")
  value   = "aspmx${count.index + 1}.migadu.com"
  proxied = false
  type    = "MX"
  ttl     = 1
  priority = (count.index + 1) * 10
}

resource "cloudflare_record" "cname_dkim" {
  count = 3

  name    = "key${count.index + 1}._domainkey"
  zone_id = lookup(data.cloudflare_zones.domain.zones[0], "id")
  value   = "key${count.index + 1}.${var.domain}._domainkey.migadu.com"
  proxied = false
  type    = "CNAME"
  ttl     = 1
}

resource "cloudflare_record" "txt_spf" {
  name    = var.domain
  zone_id = lookup(data.cloudflare_zones.domain.zones[0], "id")
  value   = "v=spf1 include:spf.migadu.com -all"
  proxied = false
  type    = "TXT"
  ttl     = 1
}

resource "cloudflare_record" "txt_dmarc" {
  name    = "_dmarc"
  zone_id = lookup(data.cloudflare_zones.domain.zones[0], "id")
  value   = "v=DMARC1; p=quarantine;"
  proxied = false
  type    = "TXT"
  ttl     = 1
}

resource "cloudflare_record" "cname_autoconfig" {
  count = var.autodiscover == true ? 1 : 0

  name    = "autoconfig"
  zone_id = lookup(data.cloudflare_zones.domain.zones[0], "id")
  value   = "autoconfig.migadu.com"
  proxied = false
  type    = "CNAME"
  ttl     = 1
}

resource "cloudflare_record" "srv_autodiscover" {
  count = var.autodiscover == true ? 1 : 0

  zone_id = lookup(data.cloudflare_zones.domain.zones[0], "id")
  name    = "_autodiscover"
  type    = "SRV"

  data {
    service  = "_autodiscover"
    proto    = "_tcp"
    name     = var.domain
    priority = 0
    weight   = 1
    port     = 443
    target   = "autodiscover.migadu.com"
  }
}

resource "cloudflare_record" "srv_submissions" {
  count = var.autodiscover == true ? 1 : 0

  zone_id = lookup(data.cloudflare_zones.domain.zones[0], "id")
  name    = "_submissions"
  type    = "SRV"

  data {
    service  = "_submissions"
    proto    = "_tcp"
    name     = var.domain
    priority = 0
    weight   = 1
    port     = 465
    target   = "smtp.migadu.com"
  }
}

resource "cloudflare_record" "srv_imaps" {
  count = var.autodiscover == true ? 1 : 0

  zone_id = lookup(data.cloudflare_zones.domain.zones[0], "id")
  name    = "_imaps"
  type    = "SRV"

  data {
    service  = "_imaps"
    proto    = "_tcp"
    name     = var.domain
    priority = 0
    weight   = 1
    port     = 993
    target   = "imap.migadu.com"
  }
}

resource "cloudflare_record" "srv_pop3s" {
  count = var.autodiscover == true ? 1 : 0

  zone_id = lookup(data.cloudflare_zones.domain.zones[0], "id")
  name    = "_pop3s"
  type    = "SRV"

  data {
    service  = "_pop3s"
    proto    = "_tcp"
    name     = var.domain
    priority = 0
    weight   = 1
    port     = 995
    target   = "pop.migadu.com"
  }
}