# Additional provider must be defined because certificates and Lambda@Edge
# functions must reside in us-east-1.

provider "aws" {
  alias  = "us-east-1"
  region = "us-east-1"
}

# Data sources are used to retrieve account number and region.

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_s3_bucket" "selected" {
  bucket = var.bucket
}

data "aws_lambda_function" "selected" {
  for_each = {
    for f in local.lambda_function_association : f["name"] => f
  }

  function_name = each.key
  qualifier     = lookup(each.value, "version", null)

  # Lambda@Edge functions must reside in us-east-1.
  provider = aws.us-east-1
}
