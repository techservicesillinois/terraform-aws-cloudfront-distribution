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

### www.foo.com in zone foo.com

```hcl
module "foo" {
  source = "git@github.com:techservicesillinois/terraform-aws-cloudfront-distribution"

  hostname = "www"
  domain = "foo.com"

  aliases = [ "static.foo.com", "bar.foo.com", ... "foo.com" ]

  bucket = "some-S3-bucket"
  origin_access_identity_path = "origin-access-identity/cloudfront/QA0DOUCO4WRZ2"

  lambda_function_association = [
    {
      name = "cloudfront-directory-index",
      version = "latest"
      event_type = "origin-request"
    }
  ]
```

### www.foo.com in zone www.foo.com

```hcl
module "foo" {
  source = "git@github.com:techservicesillinois/terraform-aws-cloudfront-distribution"

  domain = "www.foo.com"

  bucket = "some-S3-bucket"
  origin_access_identity_path = "origin-access-identity/cloudfront/QA0DOUCO4WRZ2"

  lambda_function_association = [
    {
      name = "cloudfront-directory-index",
      version = 4
      event_type = "origin-request"
    }
  ]
```

Argument Reference
-----------------

The following arguments are supported:

* `hostname` - (Optional) The primary hostname used in the S3 prefix, to create a Route 53 record, and ACM certificate.
* `domain` - (Required) The primary domain used in the S3 prefix, to create a Route 53 record, and ACM certificate.
* `bucket` - (Required) S3 bucket used as the CloudFront origin.
* `origin_access_identity_path` - (Required) CloudFront origin access identity for the S3 bucket.
* `lambda_function_association` - A
[lambda_function_association](#lambda_function_association) block
triggers a lambda function with specific actions.
* `aliases` - Extra hostnames handled by the distribution
* `create_route53_record` - If false, do not create a Route53 alias for the `hostname` in `domain` (Defaults to true).
* `create_acm_cert` - If false, do not create an ACM certificate for the `hostname` and `aliases` in `domain` (Defaults to true).
* `enabled` - Allow the distribution to accept requests. (Defaults to true).
* `log_bucket` - Log bucket (Default is log-region-account)
* `default_ttl` - Default time to live (in seconds) for object in a CloudFront cache (Default 900).
* `max_ttl` - "Maximum time to live (in seconds) for object in a CloudFront cache (Default 3600)
* `min_ttl` - "Minimum time to live (in seconds) for object in a CloudFront cache (Default 0).


lambda_function_association
---------------------------

A `lambda_function_association` block supports the following:

* `event_type` - (Required) The specific
[event](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/lambda-cloudfront-trigger-events.html)
to trigger this function. Valid values: `viewer-request`,
`origin-request`, `viewer-response`, `origin-response`.

* `name` - (Required) Name of the lambda function.

* `version` - (Optional) Alias name or version number of the lambda
function.

* `include_body` - (Optional) When set to true it exposes the request
body to the lambda function (Default: `false`)

Lambda@Edge allows you to associate an AWS Lambda Function with a
predefined event. You can associate a single function per event
type. See
[What is Lambda@Edge](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/lambda-at-the-edge.html)
for more information.

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
