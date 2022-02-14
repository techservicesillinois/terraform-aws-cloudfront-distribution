variable "name" {}

variable "policy_name" {}

variable "regions" {
  description = "Regions in which replicas should be created"
  type        = list(string)
}

variable "tags" {
  description = "A map of tags to assign to the bucket"
  type        = map(string)
  default     = {}
}
