locals {
  dns_enabled = var.enable_dns
  public_hostnames = [
    "platform.${var.root_domain}",
    "app.${var.root_domain}",
  ]
}

resource "aws_route53_zone" "root" {
  count = local.dns_enabled ? 1 : 0

  name = var.root_domain

  tags = {
    Name      = var.root_domain
    Component = "dns"
  }
}

resource "aws_acm_certificate" "public" {
  count = local.dns_enabled ? 1 : 0

  domain_name               = local.public_hostnames[0]
  subject_alternative_names = slice(local.public_hostnames, 1, length(local.public_hostnames))
  validation_method         = "DNS"

  tags = {
    Name      = "gurujix-public"
    Component = "tls"
  }

  lifecycle {
    create_before_destroy = true
  }
}
