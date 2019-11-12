locals {
  create_acm_cert = var.create_acm_cert && var.create_route53_record
  acm_cert_arn    = local.create_acm_cert ? aws_acm_certificate_validation.default[0].certificate_arn : data.aws_acm_certificate.selected[0].arn
}

data "aws_acm_certificate" "selected" {
  count = local.create_acm_cert ? 0 : 1

  provider    = "aws.us-east-1"
  domain      = local.fqdn
  statuses    = ["ISSUED"]
  most_recent = true
}

resource "aws_acm_certificate" "default" {
  count = local.create_acm_cert ? 1 : 0

  provider                  = "aws.us-east-1"
  domain_name               = local.fqdn
  subject_alternative_names = var.aliases
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "acm" {
  count = local.create_acm_cert ? length(var.aliases) + 1 : 0

  provider = "aws.us-east-1"
  name     = aws_acm_certificate.default[0].domain_validation_options[count.index]["resource_record_name"]
  type     = aws_acm_certificate.default[0].domain_validation_options[count.index]["resource_record_type"]
  zone_id  = data.aws_route53_zone.selected[0].zone_id
  ttl      = 60
  records  = [aws_acm_certificate.default[0].domain_validation_options[count.index]["resource_record_value"]]
}

resource "aws_acm_certificate_validation" "default" {
  count = local.create_acm_cert ? 1 : 0

  provider                = "aws.us-east-1"
  certificate_arn         = aws_acm_certificate.default[0].arn
  validation_record_fqdns = aws_route53_record.acm.*.fqdn
}
