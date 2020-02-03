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

variable "origin_access_identity_path" {
  description = "CloudFront origin access identity for this origin"
}

# Optional

variable "aliases" {
  description = "Extra hostnames handled by the distribution"
  type        = list(string)
  default     = []
}

variable "basic_auth" {
  description = "HTTP basic authentication block"
  type        = map(list(string))
  default     = {}
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

variable "default_ttl" {
  description = "Default time to live (in seconds) for object in a CloudFront cache"
  default     = 900
}

variable "geo_restriction" {
  description = "Location restrictions"
  type        = object({ locations = list(string), restriction_type = string })
  default = {
    locations        = null
    restriction_type = "none"
  }
}

variable "lambda_function_association" {
  description = "A config block that triggers a lambda function with specific actions"
  type        = map(map(string))
  default     = {}
}

variable "log_bucket" {
  description = "Log bucket (Default is log-region-account)"
  default     = ""
}

variable "max_ttl" {
  description = "Maximum time to live (in seconds) for object in a CloudFront cache"
  default     = 3600
}

variable "min_ttl" {
  description = "Minimum time to live (in seconds) for object in a CloudFront cache"
  default     = 0
}

variable "redirect" {
  description = "Enables appending index.html to requests ending in a slash (Default true)"
  default     = true
}
