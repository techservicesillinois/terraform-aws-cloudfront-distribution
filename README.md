# cloudfront-distribution

[![Terraform actions status](https://github.com/techservicesillinois/terraform-aws-cloudfront-distribution/workflows/terraform/badge.svg)](https://github.com/techservicesillinois/terraform-aws-cloudfront-distribution/actions)

Provides a CloudFront distribution for static content. This module
expects all content for the distribution to reside in an S3 bucket
at a prefix determined by the user supplied hostname and domain.
The prefix is the FQDN (*hostname.domain*) prepended with the first
four digits of the md5sum of the FQDN.  This is done for [performance
reasons](https://aws.amazon.com/blogs/aws/amazon-s3-performance-tips-tricks-seattle-hiring-event/).
By default an ACM certificate and Route 53 alias for the hostname
are created in the zone determined by the user supplied domain. In
addition, requests ending in slash are redirected
to `index.html` using the lambda function
[cloudfront-directory-index](https://github.com/techservicesillinois/terraform-aws-cloudfront-lambda-directory-index)
by default.

Example Usage
-----------------

### www.foo.com in zone foo.com

The FQDN is the hostname plus the domain. The domain must be an AWS
hosted zone in the example below `foo.com`. In this example then
the hostname is just `www` since the FQDN is `www.foo.com`.

```hcl
module "foo" {
  source = "git@github.com:techservicesillinois/terraform-aws-cloudfront-distribution"

  hostname = "www"
  domain = "foo.com"

  aliases = [ "static.foo.com", "bar.foo.com", ... "foo.com" ]

  bucket = "some-S3-bucket"
  origin_access_identity_path = "origin-access-identity/cloudfront/QA0DOUCO4WRZ2"
}
```

### www.foo.com in zone www.foo.com

In this example the FQDN and zone are the same. In this case we do
not specify a hostname.

```hcl
module "foo" {
  source = "git@github.com:techservicesillinois/terraform-aws-cloudfront-distribution"

  domain = "www.foo.com"

  bucket = "some-S3-bucket"
  origin_access_identity_path = "origin-access-identity/cloudfront/QA0DOUCO4WRZ2"

  lambda_function_association = {
    origin-request = {
      name = "cloudfront-directory-index",
      version = 4
    }
  }
}
```

### Basic Auth for www.foo.com

This example creates a distribution that is password protected with
[HTTP basic authentication](https://tools.ietf.org/html/rfc7617).
The username and passwords are stored in DynamoDB tables in the
regions specified (i.e. `us-east-1`, `us-east-2`, `us-west-1`,
`us-west-2`). The master table resides in the same region as the
distribution itself. This example uses geo restrictions to prevent
access outside the United States. Basic auth is performed using the
lambda function
[cloudfront-basic-auth](https://github.com/techservicesillinois/terraform-aws-cloudfront-lambda-basic-auth).
which must be deployed separately.

```hcl
module "foo" {
  source = "git@github.com:techservicesillinois/terraform-aws-cloudfront-distribution"

  domain = "www.foo.com"

  bucket = "some-S3-bucket"
  origin_access_identity_path = "origin-access-identity/cloudfront/QA0DOUCO4WRZ2"

  basic_auth = {
    regions = ["us-east-1", "us-east-2", "us-west-1", "us-west-2"]
  }

  geo_restriction = {
    locations = ["US"]
    restriction_type = "whitelist"
  }
}
```

Argument Reference
-----------------

The following arguments are supported:

* `hostname` - (Optional) The primary hostname used in the S3 prefix, to create a Route 53 record, and ACM certificate.
* `domain` - (Required) The primary domain used in the S3 prefix, to create a Route 53 record, and ACM certificate.
* `bucket` - (Required) S3 bucket used as the CloudFront origin.
* `origin_access_identity_path` - (Required) CloudFront origin access identity for the S3 bucket.
* `aliases` - Extra hostnames handled by the distribution
* `basic_auth` - [HTTP basic authentication](#basic_auth) block.
* `create_route53_record` - If false, do not create a Route53 alias for the `hostname` in `domain` (Defaults to true).
* `create_acm_cert` - If false, do not create an ACM certificate for the `hostname` and `aliases` in `domain` (Defaults to true).
* `enabled` - Allow the distribution to accept requests. (Defaults to true).
* `log_bucket` - Log bucket (Default is log-region-account)
* `lambda_function_association` - A
  [lambda_function_association](#lambda_function_association) block
  triggers a lambda function with specific actions.
* `default_ttl` - Default time to live (in seconds) for object in a CloudFront cache (Default 900).
* `geo_restriction` - [Location restrictions](#geo_restriction) block
* `max_ttl` - Maximum time to live (in seconds) for object in a CloudFront cache (Default 3600)
* `min_ttl` - Minimum time to live (in seconds) for object in a CloudFront cache (Default 0).
* `redirect` - Enables appending index.html to requests ending in a slash (Default true).

basic_auth
---------------------------

A `basic_auth` block supports the following:

* `regions` - A list of AWS region names where to create DynamoDB tables.
* `policy_name` - (Optional) The name of the DynamoDB IAM policy.

If configured the module will create global DynamodDB tables named
`CloudFront-Basic-Auth-DistributionID` in the regions specified.
The master table resides in the same region as the CloudFront
Distribution, and must be included in the list of regions. The
tables are used to store username and passwords for use with the
Lambda@Edge function
[cloudfront-basic-auth](https://github.com/techservicesillinois/terraform-aws-cloudfront-lambda-basic-auth).
This function must be deployed separately and is required.

geo_restriction
---------------------------

A `geo_restriction` block supports the following:

* `locations` - (Required) The [ISO
3166-1-alpha-2](https://www.iso.org/iso-3166-country-codes.html)
codes for which you want CloudFront either to distribute your
content (`whitelist`) or not distribute your content (`blacklist`).

* `restriction_type` - (Required) The method that you want to use
to restrict distribution of your content by country: `whitelist`,
or `blacklist`.

lambda_function_association
---------------------------

The lambda_function_association block takes up to four
[event](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/lambda-cloudfront-trigger-events.html)
blocks. Valid values: `viewer-request`, `origin-request`,
`viewer-response`, `origin-response`.

The arguments of each event block are:

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
* `dynamodb_table_name` - Name of the DynamoDB table holding credentials for HTTP basic authentication.
* `log_bucket` - Name of log bucket used for distribution.
* `s3_prefix` - Prefix of this distribution within the origin S3 bucket.

Credits
--------------------

**Nota bene** the vast majority of the verbiage on this page was
taken directly from the Terraform manual, and in a few cases from
Amazon's documentation.
