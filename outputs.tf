output "cert_arn" {
  description = "ACM certificate attached to the CloudFront distribution"
  value       = data.aws_acm_certificate.selected.arn
}

output "cloudfront_domain_name" {
  description = "Full domain name of CloudFront distribution"
  value       = aws_cloudfront_distribution.default.domain_name
}

output "log_bucket" {
  description = "Name of log bucket used for distribution"
  value       = local.log_bucket
}

output "s3_prefix" {
  description = "Prefix of this distribution within the origin S3 bucket"
  value       = local.origin_path
}
