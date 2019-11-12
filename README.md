# cloudfront-distribution

[![Build Status](https://drone.techservices.illinois.edu/api/badges/techservicesillinois/terraform-aws-cloudfront-distribution/status.svg)](https://drone.techservices.illinois.edu/techservicesillinois/terraform-aws-cloudfront-distribution)

Provides a CloudFront distribution for static content. This module
expects all content for the distribution to reside in an S3 bucket
at a prefix determined by the user supplied hostname and domain.
The prefix is the FQDN (*hostname.domain*) prepended with the first
four digits of the md5sum of the FQDN.  This is done for [performance
reasons](https://aws.amazon.com/blogs/aws/amazon-s3-performance-tips-tricks-seattle-hiring-event/).
By default an ACM certificate and Route 53 alias for the hostname
are created in the zone determined by the user supplied domain.

Example Usage
-----------------

```hcl
module "foo" {
  source = "git@github.com:techservicesillinois/terraform-aws-cloudfront-distribution"

  hostname = "www"
  domain = "foo.com"

  aliases = [ "static.foo.com", "bar.foo.com", ... "foo.com" ]

  bucket = "some-S3-bucket"
  origin_access_identity_path = "origin-access-identity/cloudfront/QA0DOUCO4WRZ2"

  cloudfront_lambda_origin_request_arn = "arn:aws:lambda:us-east-1:617683844790:function:cloudfront-directory-index:1"
```

Argument Reference
-----------------

The following arguments are supported:

* `hostname` - (Required) The primary hostname used in the S3 prefix, to create a Route 53 record, and ACM certificate.
* `domain` - (Required) The primary domain used in the S3 prefix, to create a Route 53 record, and ACM certificate.
* `bucket` - (Required) S3 bucket used as the CloudFront origin.
* `origin_access_identity_path` - (Required) CloudFront origin access identity for the S3 bucket.
* `cloudfront_lambda_origin_request_arn` - (Required) ARN of Lambda@Edge function to be run for origin request.
* `aliases` - Extra hostnames handled by the distribution
* `create_route53_record` - If false, do not create a Route53 alias for the `hostname` in `domain` (Defaults to true).
* `create_acm_cert` - If false, do not create an ACM certificate for the `hostname` and `aliases` in `domain` (Defaults to true).
* `enabled` - Allow the distribution to accept requests. (Defaults to true).
* `log_bucket` - Log bucket (Default is log-region-account)
* `default_ttl` - Default time to live (in seconds) for object in a CloudFront cache (Default 900).
* `max_ttl` - "Maximum time to live (in seconds) for object in a CloudFront cache (Default 3600)
* `min_ttl` - "Minimum time to live (in seconds) for object in a CloudFront cache (Default 0).

Attributes Reference
--------------------

The following attributes are exported:

* `cert_arn` - ACM certificate attached to the CloudFront distribution.
* `cloudfront_domain_name` - Full domain name of CloudFront distribution.
* `log_bucket` - Name of log bucket used for distribution.
* `s3_prefix` - Prefix of this distribution within the origin S3 bucket.

Credits
--------------------

**Nota bene** the vast majority of the verbiage on this page was
taken directly from the Terraform manual, and in a few cases from
Amazon's documentation.
