# Manage Route 53 alias record for public zone.

data "aws_route53_zone" "selected" {
  count = var.create_route53_record ? 1 : 0

  name = var.domain
}

resource "aws_route53_record" "default" {
  count = var.create_route53_record ? 1 : 0

  # Zone and name of Route53 record being managed.
  zone_id = data.aws_route53_zone.selected[0].zone_id
  name    = var.hostname
  type    = "A"

  alias {
    # Target of Route53 alias.
    name                   = aws_cloudfront_distribution.default.domain_name
    evaluate_target_health = true

    # For cloudfront zone_id is Z2FDTNDATAQYW2
    # https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-properties-route53-aliastarget.html#cfn-route53-aliastarget-hostedzoneid
    zone_id = "Z2FDTNDATAQYW2"
  }
}
