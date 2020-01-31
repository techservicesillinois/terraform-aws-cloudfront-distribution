locals {
  bucket_arn         = data.aws_s3_bucket.selected.arn
  bucket_name        = data.aws_s3_bucket.selected.id
  bucket_origin_id   = "S3-${data.aws_s3_bucket.selected.id}"
  default_log_bucket = "log-${data.aws_region.current.name}-${data.aws_caller_identity.current.account_id}"
  fqdn               = length(var.hostname) > 0 ? "${var.hostname}.${var.domain}" : "${var.domain}"

  # User can override log bucket name.
  log_bucket                  = var.log_bucket != "" ? var.log_bucket : local.default_log_bucket
  origin_access_identity_path = var.origin_access_identity_path
  origin_path                 = format("%s-%s", substr(md5(local.fqdn), 0, 4), local.fqdn)

  basic_auth = { viewer-request = { name = "cloudfront-basic-auth", version = "latest" } }
  redirect   = { origin-request = { name = "cloudfront-directory-index", version = "latest" } }

  lambda_function_association = var.redirect && length(var.basic_auth) > 0 ? merge(
    local.basic_auth, local.redirect, var.lambda_function_association
    ) : var.redirect ? merge(local.redirect, var.lambda_function_association
    ) : length(var.basic_auth) > 0 ? merge(local.basic_auth, var.lambda_function_association
  ) : var.lambda_function_association
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

    dynamic "lambda_function_association" {
      for_each = local.lambda_function_association
      iterator = each

      content {
        event_type = each.key
        lambda_arn = format("%s:%s",
          data.aws_lambda_function.selected[
            lookup(each.value, "name")
          ].arn,
          data.aws_lambda_function.selected[
            lookup(each.value, "name")
          ].version
        )
        include_body = lookup(each.value, "include_body", null)
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    default_ttl            = var.default_ttl
    max_ttl                = var.max_ttl
    min_ttl                = var.min_ttl
  }

  restrictions {
    geo_restriction {
      locations        = lookup(var.geo_restriction, "locations")
      restriction_type = lookup(var.geo_restriction, "restriction_type")
    }
  }

  viewer_certificate {
    acm_certificate_arn      = local.acm_cert_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1"
  }
}
