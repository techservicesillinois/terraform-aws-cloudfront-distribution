# Additional provider needed because certificates reside in us-east-1.

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
