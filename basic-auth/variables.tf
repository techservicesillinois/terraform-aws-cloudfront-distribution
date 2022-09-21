variable "name" {}

variable "policy_name" {}

variable "regions" {
  description = "Regions in which replicas should be created"
  type        = list(string)
}

variable "tags" {
  description = "Map of tags to assign to resources where supported"
  type        = map(string)
  default     = {}
}
