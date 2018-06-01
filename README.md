# cloudfront-distribution

Provides an CloudFront distribution; currently only supports static content.

Example Usage
-----------------

```hcl
module "foo" {
  source = "git@github.com:techservicesillinois/terraform-aws-cloudfront-distribution"

  name = "distributionName"
  aliases = [ "alias1", "alias2", ... "aliasN" ]
  bucket = "bucketName"
  certificate_arn = "certificateARN" 
  hostname = "virtualHostname"
  origin_access_identity_path" = "oaiPath"
}
```

Argument Reference
-----------------

The following arguments are supported:

* `name` - (Required) Name of the repository.
* `aliases` - Aliases (hostnames handled by the distribution).
* `bucket` - (Required) S3 bucket used for CloudFront origin.
* `certificate_arn` - (Required for HTTP distributions) ARN of the AWS Certificate Manager certificate for distribution.
* `enable` - Allow the distribution to accept requests. (Defaults to "true".)
* `hostname` - (Required) Logical hostname; used to derive prefix within S3 bucket.
* `cloudfront_lambda_origin_request_arn` - (Required) ARN of Lambda@Edge function to be run for origin request.
* `log_bucket` - Log bucket. **NOTE**: This is not required, as the built-in default is suitable in most cases.
* `origin_access_identity_path` - (Required) CloudFront origin access identity for this origin.
* `default_ttl` - Default time to live (in seconds) for object in a CloudFront cache.
* `max_ttl` - "Maximum time to live (in seconds) for object in a CloudFront cache.
* `min_ttl` - "Minimum time to live (in seconds) for object in a CloudFront cache.

Attributes Reference
--------------------

The following attributes are exported:

* `cloudfront_domain_name` - Full domain name of CloudFront distribution.
* `log_bucket` - Name of log bucket used for distribution.
* `s3_prefix` - Prefix of this distribution within the hosting S3 bucket.

Credits
--------------------

**Nota bene** the vast majority of the verbiage on this page was
taken directly from the Terraform manual, and in a few cases from
Amazon's documentation.
