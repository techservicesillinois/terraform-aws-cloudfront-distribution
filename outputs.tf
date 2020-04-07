output "id" {
  description = "The identifier for the distribution"
  value       = aws_cloudfront_distribution.default.id
}

output "cert_arn" {
  description = "ACM certificate attached to the CloudFront distribution"
  value       = local.acm_cert_arn
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

output "policy_arn" {
  description = "DynamoDB admin policy ARN"
  value       = module.basic-auth.policy_arn
}
