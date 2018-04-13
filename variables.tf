variable "aliases" {
  default     = []
  description = "Aliases (hostnames handled by the distribution)"
}

variable "bucket" {
  description = "S3 bucket used for this CloudFront origin"
}

variable "certificate_arn" {
  description = "ARN of the AWS Certificate Manager certificate for distribution"
}

variable "enabled" {
  default     = "true"
  description = "Allow the distribution to accept requests"
}

variable "hostname" {
  description = "Logical hostname; used to derive prefix within S3 bucket"
}

variable "cloudfront_lambda_origin_request_arn" {
  description = "ARN of Lambda@Edge function to be run for origin request"
}

variable "origin_access_identity_path" {
  description = "CloudFront origin access identity for this origin"
}

variable "default_ttl" {
  default     = "900"
  description = "Default time to live (in seconds) for object in a CloudFront cache"
}

variable "max_ttl" {
  default     = "3600"
  description = "Maximum time to live (in seconds) for object in a CloudFront cache"
}

variable "min_ttl" {
  default     = "0"
  description = "Minimum time to live (in seconds) for object in a CloudFront cache"
}
