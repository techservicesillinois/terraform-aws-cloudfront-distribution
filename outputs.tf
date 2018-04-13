output "cloudfront_domain_name" {
  value = "${aws_cloudfront_distribution.default.domain_name}"
}

output "s3_prefix" {
  value = "${local.origin_path}"
}
