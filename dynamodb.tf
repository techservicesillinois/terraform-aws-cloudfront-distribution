module "basic-auth" {
  source = "./basic-auth"

  count       = (length(var.basic_auth) == 0) ? 0 : 1
  name        = format("CloudFront-Basic-Auth-%s", aws_cloudfront_distribution.default.id)
  regions     = lookup(var.basic_auth, "regions", [])
  policy_name = lookup(var.basic_auth, "policy_name", "")
  tags        = var.tags
}
