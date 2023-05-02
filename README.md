# cloudfront-distribution

[![Terraform actions status](https://github.com/techservicesillinois/terraform-aws-cloudfront-distribution/workflows/terraform/badge.svg)](https://github.com/techservicesillinois/terraform-aws-cloudfront-distribution/actions)

Provides a CloudFront distribution for static (read-only) content residing in a zone hosted in Route 53.

This module expects all content for the distribution to reside in an S3 bucket
which is served by CloudFront. Authorized administrators and applications can manage
this content through the Amazon S3 API (including the AWS command line interface (CLI).

This module supports multiple distinct CloudFront distributions sharing a single S3 bucket, with each distribution rooted at a top-level key within the shared bucket.
By default, the *prefix* – the top-level key referred to above – is the distribution's fully-qualified domain name (FQDN) prefixed with the first four hexidecimal digits of the MD5 checksum computed from that FQDN.

The intent of this hash was to improve performance based on [recommendations to optimize for legacy S3 behavior](https://aws.amazon.com/blogs/aws/amazon-s3-performance-tips-tricks-seattle-hiring-event/). Current  [best practices for optimizing S3 performance](https://docs.aws.amazon.com/whitepapers/latest/s3-optimizing-performance-best-practices/introduction.html) no longer requires this prefix.

By default, an ACM certificate and Route 53 alias for the hostname
are created in the zone determined by the user-supplied Route 53 domain.
In addition, requests ending in `/` are appended with `index.html`, and redirected
by using the
[cloudfront-directory-index](https://github.com/techservicesillinois/terraform-aws-cloudfront-lambda-directory-index) lambda function. This default behavior can be overridden.

Example Usage
-----------------

### Server FQDN of `www.foo.com` (record within zone)

This example creates a CloudFront distribution, and a Route 53 alias record to
allow the CloudFront content to be referenced by the FQDN `www.foo.com`.
Presumably additional Route 53 records reside in the `foo.com` zone.
In this case, the module creates a Route 53 alias record `www` that resides in zone `foo.com`. The FQDN is formed by concatenating the hostname with the name of the zone.

```hcl
module "foo" {
  source = "git@github.com:techservicesillinois/terraform-aws-cloudfront-distribution"

  domain   = "foo.com"
  hostname = "www"

  aliases                     = [ "static.foo.com", "bar.foo.com", "foo.com" ]
  bucket                      = "some-S3-bucket"
  origin_access_identity_path = "origin-access-identity/cloudfront/QA0DOUCO4WRZ2"
}
```

### Server FQDN is `bar.com` (record at apex of zone)

This example creates a CloudFront distribution which is referenced by the FQDN
`bar.com`. This is said to be the *apex* of the zone, so in this case, we either omit the hostname or explicitly assign it a `null` value.

```hcl
module "bar" {
  source = "git@github.com:techservicesillinois/terraform-aws-cloudfront-distribution"

  domain   = "bar.com"
  hostname = null        # Explicitly omit hostname.

  bucket                      = "some-S3-bucket"
  origin_access_identity_path = "origin-access-identity/cloudfront/QA0DOUCO4WRZ2"

  lambda_function_association = {
    origin-request = {
      name    = "cloudfront-directory-index",
      version = 4
    }
  }
}
```

### HTTP basic authentication for `www.foo.com`

This example creates a distribution that is password-protected with
[HTTP basic authentication](https://tools.ietf.org/html/rfc7617).
The usernames and passwords are stored in a DynamoDB table in the same
region as the CloudFront distribution itself. DynamoDB replicas are
deployed in the regions specified (e.g. `us-east-1`, `us-east-2`,
`us-west-1`, `us-west-2`).

This example uses geo restrictions to prevent access from outside the
United States. **NOTE:** Regardless of geo restrictions, the Lambda@Edge
invocation can occasionally take place in regions other than those
specified if Amazon's algorithms route traffic there. Specify a wildcard `["*"]`
to create DynamoDB replica tables in *all* supported (and opted-in) AWS regions.

HTTP basic authentication is performed using the lambda function
[cloudfront-basic-auth](https://github.com/techservicesillinois/terraform-aws-cloudfront-lambda-basic-auth), which must be deployed separately before being used.

This module version only supports [version 2019.11.21](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/globaltables.V2.html) version of
DynamoDB global tables.

```hcl
module "foo" {
  source = "git@github.com:techservicesillinois/terraform-aws-cloudfront-distribution"

  domain   = "foo.com"
  hostname = "www"

  bucket                      = "some-S3-bucket"
  origin_access_identity_path = "origin-access-identity/cloudfront/QA0DOUCO4WRZ2"

  basic_auth = {
    regions = ["us-east-1", "us-east-2", "us-west-1", "us-west-2"]
  }

  geo_restriction = {
    locations        = ["US"]
    restriction_type = "whitelist"
  }
}
```

This example deploys DynamoDB replica tables to all supported regions, 
and does not use geo restrictions.

```hcl
module "foo" {
  source = "git@github.com:techservicesillinois/terraform-aws-cloudfront-distribution"

  domain                      = "www.foo.com"
  bucket                      = "some-S3-bucket"
  origin_access_identity_path = "origin-access-identity/cloudfront/QA0DOUCO4WRZ2"

  basic_auth = {
    regions = ["*"]
  }
}
```
**NOTE:** Regardless of whether Lambda@Edge functions are defined for a CloudFront
distribution, the ACM certificate is searched for or created in the `us-east-1` region,
and the ACM certificate validation resource must reside there as well. You will *not*
find these resources in the AWS console, CLI, or API unless you issue the request
in the `us-east-1` region.

Argument Reference
-----------------

The following arguments are supported:

* `aliases` - (Optional) Extra hostnames handled by the distribution.

* `basic_auth` - (Optional) [HTTP basic authentication](#basic_auth) block.

* `bucket` - (Required) S3 bucket used as the CloudFront origin.

* `create_acm_cert` - If false, do not create an ACM certificate for the `hostname` and `aliases` in `domain`. (Defaults to true.)

* `create_route53_record` - If false, do not create a Route53 alias for the `hostname` in `domain`. (Defaults to true.)

* `domain` - (Required) The primary domain used in the S3 prefix, to create a Route 53 record, and ACM certificate.

* `enabled` - (Optional) Allow the distribution to accept requests. (Defaults to true).

* `geo_restriction` - [Location restriction](#geo_restriction) block, controls the countries from which users may or may not access your content.

* `hostname` - (Optional) The primary hostname used in the S3 prefix, to create a Route 53 record, and ACM certificate.

* `lambda_function_association` - (Optional) A
  [lambda\_function\_association](#lambda_function_association) block
  defines specific Lambda@Edge functions to be invoked for particular actions.

* `log_bucket` - (Optional) Log bucket (default is `uiuc-logs-account-region`.)

* `origin_access_identity_path` - (Required) CloudFront origin access identity for the S3 bucket.

* `origin_path` - (Optional) Set specific origin path within S3 bucket instead of default value derived from FQDN.

* `price_class` - (Optional) Price class for this distribution. (Defaults to `PriceClass_All`.)

* `redirect` - (Optional) Enables appending index.html to requests ending in a slash (Defaults to true).

* `tags` - (Optional) Tags to be applied to resources where supported.

* `ttl` - (Optional) A [time-to-live](#ttl) block.

basic\_auth
---------------------------

A `basic_auth` block supports the following:

* `regions` - A list of AWS region names where to create DynamoDB table replicas. A special case is a region list consisting of a single element containing the value "*" means that DynamoDB replica tables are deployed globally in all supported, opted-in
regions.

* `policy_name` - (Optional) The name of the IAM policy for the DynamoDB table.

If configured the module will create a DynamodDB table named in a format
like `CloudFront-Basic-Auth-DistributionID`, with replicas in the regions
specified.

DynamoDB is used to store username and password pairs used by the
Lambda@Edge function
[cloudfront-basic-auth](https://github.com/techservicesillinois/terraform-aws-cloudfront-lambda-basic-auth) to perform HTTP basic authentication. **NOTE:** This lambda function is must be deployed separately before creating a CloudFront distribution using 
HTTP basic authentication.

geo\_restriction
---------------------------

A `geo_restriction` block controls the countries from which users are allowed to access your content ("allow list"), or the countries from which users are prevented from accessing your content ("block list").
The block consists of the following attributes:

* `locations` - (Required) The [ISO
3166-1-alpha-2](https://www.iso.org/iso-3166-country-codes.html)
codes for which you want CloudFront either to distribute your
content (`whitelist`) or not distribute your content (`blacklist`).

* `restriction_type` - (Required) The method that you want to use
to restrict distribution of your content by country: `whitelist`,
`blacklist`, or `none`.

lambda\_function\_association
---------------------------

The lambda\_function\_association block takes up to four
[event](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/lambda-cloudfront-trigger-events.html)
blocks. Valid values: `origin-request`, `origin-response`, `viewer-request`, `viewer-response`.

The arguments of each event block are:

* `name` - (Required) Name of the lambda function.

* `version` - (Optional) Alias name or version number of the lambda
function.

* `include_body` - (Optional) When true, the request body is exposed to the lambda function (Default: `false`)

Lambda@Edge allows you to associate an AWS lambda function with a predefined event.
You can associate a single function per event type. See
[Customizing at the edge with Lambda@Edge](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/lambda-at-the-edge.html)
for more information.

ttl
---------------------------

A `ttl` block supports the following:

* `default` - Default time to live (in seconds) for object in a CloudFront cache.

* `max` - Maximum time to live (in seconds) for object in a CloudFront cache.

* `min` - Minimum time to live (in seconds) for object in a CloudFront cache.

Attributes Reference
--------------------

The following attributes are exported:

* `certificate_arn` - ARN of ACM certificate attached to the CloudFront distribution.

* `cloudfront_domain_name` - Full domain name of CloudFront distribution.

* `dynamodb_table_name` - Name of the DynamoDB table holding credentials if configured for HTTP basic authentication.

* `id` - Cloudfront distribution ID.

* `log_bucket` - Name of S3 bucket used for logging from distribution.

* `s3_prefix` - Prefix of this distribution within the origin S3 bucket.

Credits
--------------------

**Nota bene** the vast majority of the verbiage on this page was
taken directly from the Terraform manual, and in a few cases from
Amazon's documentation.
