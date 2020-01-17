# Required

variable "hostname" {
  description = "The primary hostname used in the S3 prefix, to create Route 53 records, and ACM certificates."
  default     = ""
}

variable "domain" {
  description = "The primary domain used in the S3 prefix, to create Route 53 records, and ACM certificates."
}

variable "bucket" {
  description = "S3 bucket used as the CloudFront origin"
  type        = string
}

variable "lambda_function_association" {
  description = "A config block that triggers a lambda function with specific actions"
  type        = map(map(string))
  default     = {}
}

variable "origin_access_identity_path" {
  description = "CloudFront origin access identity for this origin"
}

# Optional

variable "aliases" {
  description = "Extra hostnames handled by the distribution"
  type        = list(string)
  default     = []
}

variable "create_route53_record" {
  description = "If false, do not create Route53 alias"
  default     = true
}

variable "create_acm_cert" {
  description = "If false, do not create ACM cert"
  default     = true
}

variable "enabled" {
  description = "Allow the distribution to accept requests"
  default     = true
}

variable "log_bucket" {
  description = "Log bucket (Default is log-region-account)"
  default     = ""
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
