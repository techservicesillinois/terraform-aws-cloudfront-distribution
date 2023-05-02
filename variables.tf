variable "aliases" {
  description = "Extra hostnames handled by the distribution"
  type        = list(string)
  default     = []
}

variable "basic_auth" {
  description = "HTTP basic authentication block"
  type        = any
  default     = {}
}

variable "bucket" {
  description = "S3 bucket used as the CloudFront origin"
  type        = string
}

variable "create_acm_cert" {
  description = "If false, do not create ACM cert"
  default     = true
}

variable "create_route53_record" {
  description = "If false, do not create Route53 alias"
  default     = true
}

variable "domain" {
  description = "The primary domain used in the S3 prefix, to create Route 53 records, and ACM certificates."
}

variable "enabled" {
  description = "Allow the distribution to accept requests"
  default     = true
}

variable "geo_restriction" {
  description = "Location restrictions"
  type = object({
    locations        = list(string)
    restriction_type = string
  })
  default = {
    locations        = null
    restriction_type = "none"
  }
}

variable "hostname" {
  description = "The primary hostname used in the S3 prefix, to create Route 53 records, and ACM certificates."
  default     = null
}

variable "lambda_function_association" {
  description = "A config block that triggers a lambda function with specific actions"
  type        = map(map(string))
  default     = {}
}

variable "log_bucket" {
  description = "Log bucket (Default is log-region-account)"
  default     = null
}

variable "origin_access_identity_path" {
  description = "CloudFront origin access identity for this origin"
}

variable "origin_path" {
  description = "Set specific origin path within S3 bucket instead of default value derived from FQDN"
  default     = null
}

variable "price_class" {
  description = "Price class for this distribution"
  default     = "PriceClass_All"
}

variable "redirect" {
  description = "Enables appending index.html to requests ending in a slash (Defaults to true)"
  default     = true
}

variable "tags" {
  description = "Tags to be applied to resources where supported"
  type        = map(string)
  default     = {}
}

variable "ttl" {
  description = "Time-to-live configuration"
  type = object({
    default = optional(number, null)
    max     = optional(number, null)
    min     = optional(number, null)
  })
  default = {}
}
