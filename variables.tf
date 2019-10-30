variable "aliases" {
  description = "Aliases (hostnames handled by the distribution)"
  type        = list(string)
  default     = []
}

variable "bucket" {
  description = "S3 bucket used for this CloudFront origin"
}

variable "certificate_arn" {
  description = "ARN of the AWS Certificate Manager certificate for distribution"
}

variable "enabled" {
  description = "Allow the distribution to accept requests"
  default     = true
}

variable "hostname" {
  description = "Logical hostname; used to derive prefix within S3 bucket"
}

variable "log_bucket" {
  description = "Log bucket (if overriding module default)"
  default     = ""
}

variable "cloudfront_lambda_origin_request_arn" {
  description = "ARN of Lambda@Edge function to be run for origin request"
}

variable "origin_access_identity_path" {
  description = "CloudFront origin access identity for this origin"
}

variable "default_ttl" {
  description = "Default time to live (in seconds) for object in a CloudFront cache"
  default     = 900
}

variable "max_ttl" {
  description = "Maximum time to live (in seconds) for object in a CloudFront cache"
  default     = 3600
}

variable "min_ttl" {
  description = "Minimum time to live (in seconds) for object in a CloudFront cache"
  default     = 0
}
