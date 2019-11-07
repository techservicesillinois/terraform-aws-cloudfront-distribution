locals {
  bucket_arn         = data.aws_s3_bucket.selected.arn
  bucket_name        = data.aws_s3_bucket.selected.id
  bucket_origin_id   = "S3-${data.aws_s3_bucket.selected.id}"
  default_log_bucket = "log-${data.aws_region.current.name}-${data.aws_caller_identity.current.account_id}"
  fqdn               = "${var.hostname}.${var.domain}"

  # User can override log bucket name.
  log_bucket                  = var.log_bucket != "" ? var.log_bucket : local.default_log_bucket
  origin_access_identity_path = var.origin_access_identity_path
  origin_path                 = format("%s-%s", substr(md5(local.fqdn), 0, 4), local.fqdn)
}

# Cloudfront distribution.

resource "aws_cloudfront_distribution" "default" {
  origin {
    domain_name = data.aws_s3_bucket.selected.bucket_domain_name
    origin_path = "/${local.origin_path}"
    origin_id   = local.bucket_origin_id

    s3_origin_config {
      origin_access_identity = local.origin_access_identity_path
    }
  }

  aliases             = compact(concat([local.fqdn], var.aliases))
  comment             = local.fqdn
  enabled             = var.enabled
  is_ipv6_enabled     = true
  default_root_object = "index.html"
  price_class         = "PriceClass_All"
  retain_on_delete    = false

  logging_config {
    include_cookies = false
    bucket          = "${local.log_bucket}.s3.amazonaws.com"
    prefix          = "cloudfront/${local.fqdn}/"
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.bucket_origin_id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    lambda_function_association {
      event_type = "origin-request"
      lambda_arn = var.cloudfront_lambda_origin_request_arn
    }

    viewer_protocol_policy = "redirect-to-https"
    default_ttl            = var.default_ttl
    max_ttl                = var.max_ttl
    min_ttl                = var.min_ttl
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = data.aws_acm_certificate.selected.arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1"
  }
}
