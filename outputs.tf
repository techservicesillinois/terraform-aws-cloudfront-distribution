output "cert_arn" {
  value = data.aws_acm_certificate.selected.arn
}

output "cloudfront_domain_name" {
  value = aws_cloudfront_distribution.default.domain_name
}

output "log_bucket" {
  value = local.log_bucket
}

output "s3_prefix" {
  value = local.origin_path
}
