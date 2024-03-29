output "certificate_arn" {
  description = "ACM certificate attached to the CloudFront distribution"
  value       = local.certificate_arn
}

output "cloudfront_domain_name" {
  description = "Full domain name of CloudFront distribution"
  value       = aws_cloudfront_distribution.default.domain_name
}

output "dynamodb_table_name" {
  description = "DynamoDB table name"
  value       = (length(var.basic_auth) > 0) ? module.basic-auth[0].dynamodb_table[0].name : null
}

output "id" {
  description = "The identifier for the distribution"
  value       = aws_cloudfront_distribution.default.id
}

output "log_bucket" {
  description = "Name of S3 bucket used for logging from distribution"
  value       = local.log_bucket
}

output "policy_arn" {
  description = "DynamoDB admin policy ARN"
  value       = (length(var.basic_auth) > 0) ? module.basic-auth[0].policy_arn : null
}

output "s3_prefix" {
  description = "Prefix of this distribution within the origin S3 bucket"
  value       = local.origin_path
}

# Debug output.

#output "known_regions" {
# description = "Regions that are available and opted-in"
# value       = (length(var.basic_auth) > 0) ? module.basic-auth[0].known_regions : null
#}

# Debug output.

#output "replica_regions" {
# description = "Regions in which DynamoDB replicas are deployed"
# value       = (length(var.basic_auth) > 0) ? module.basic-auth[0].replica_regions : null
#}
