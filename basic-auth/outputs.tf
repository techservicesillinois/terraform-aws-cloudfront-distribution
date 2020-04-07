output "policy_arn" {
  value = length(var.regions) > 0 && var.policy_name != "" ? aws_iam_policy.default[0].arn : null
}
