output "policy_arn" {
  value = length(var.regions) > 0 && var.policy_name != "" ? aws_iam_policy.default[0].arn : null
}

output "dynamodb_table" {
  value = length(var.regions) > 0 ? aws_dynamodb_global_table.default[0] : null
}
