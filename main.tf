# Get S3 prefix for CloudFront distribution.

locals {
  bucket_arn                  = data.aws_s3_bucket.selected.arn
  bucket_name                 = data.aws_s3_bucket.selected.id
  bucket_origin_id            = "S3-${data.aws_s3_bucket.selected.id}"
  default_log_bucket          = format("uiuc-logs-%s-%s", data.aws_caller_identity.current.account_id, data.aws_region.current.name)
  fqdn                        = try(length(var.hostname) > 0, false) ? format("%s.%s", var.hostname, var.domain) : var.domain
  log_bucket                  = var.log_bucket != null ? var.log_bucket : local.default_log_bucket
  origin_access_identity_path = var.origin_access_identity_path
  override_origin_path        = try(length(var.origin_path) > 0, false)
}

module "s3-prefix" {
  # NOTE: Use canonical GitHub URL to make GitHub Actions happy.
  source = "github.com/techservicesillinois/terraform-aws-util//modules/compute-s3-prefix?ref=v3.0.4"

  for_each = toset(local.override_origin_path ? [] : [local.fqdn])

  fqdn = each.value
}

locals {
  origin_path = local.override_origin_path ? var.origin_path : module.s3-prefix[local.fqdn].prefix

  basic_auth = {
    viewer-request = {
      name    = "cloudfront-basic-auth"
      version = "latest"
    }
  }
  redirect = {
    origin-request = {
      name    = "cloudfront-directory-index",
      version = "latest"
    }
  }

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
  is_ipv6_enabled     = false
  default_root_object = "index.html"
  price_class         = var.price_class
  retain_on_delete    = false
  tags                = var.tags

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
          data.aws_lambda_function.selected[each.value.name].arn,
          data.aws_lambda_function.selected[each.value.name].version,
        )
        include_body = try(each.value.include_body, null)
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    default_ttl            = var.ttl.default
    max_ttl                = var.ttl.max
    min_ttl                = var.ttl.min
  }

  restrictions {
    geo_restriction {
      locations        = var.geo_restriction.locations
      restriction_type = var.geo_restriction.restriction_type
    }
  }

  viewer_certificate {
    acm_certificate_arn      = local.certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1"
  }
}
