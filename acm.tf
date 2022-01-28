locals {
  create_acm_cert = var.create_acm_cert && var.create_route53_record
  acm_cert_arn    = local.create_acm_cert ? aws_acm_certificate_validation.default[0].certificate_arn : data.aws_acm_certificate.selected[0].arn
}

data "aws_acm_certificate" "selected" {
  count = local.create_acm_cert ? 0 : 1

  provider = aws.us-east-1

  domain      = local.fqdn
  statuses    = ["ISSUED"]
  most_recent = true
}

resource "aws_acm_certificate" "default" {
  count = local.create_acm_cert ? 1 : 0

  provider = aws.us-east-1

  domain_name               = local.fqdn
  subject_alternative_names = var.aliases
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "acm" {
  for_each = {
    for dvo in(local.create_acm_cert ? aws_acm_certificate.default[0].domain_validation_options : toset([])) : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  name    = each.value.name
  records = [each.value.record]
  ttl     = 60
  type    = each.value.type
  zone_id = data.aws_route53_zone.selected[0].zone_id
}

resource "aws_acm_certificate_validation" "default" {
  count = local.create_acm_cert ? 1 : 0

  provider = aws.us-east-1

  certificate_arn         = aws_acm_certificate.default[0].arn
  validation_record_fqdns = [for r in aws_route53_record.acm : r.fqdn]
}
