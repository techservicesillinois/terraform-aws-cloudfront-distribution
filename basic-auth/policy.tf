data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
  region     = data.aws_region.current.name
}

data "aws_iam_policy_document" "default" {
  count = length(var.regions) > 0 ? 1 : 0

  statement {
    actions = [
      "dynamodb:DeleteItem",
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:Query",
      "dynamodb:Scan",
      "dynamodb:UpdateItem",
    ]

    resources = ["arn:aws:dynamodb:${local.region}:${local.account_id}:table/${aws_dynamodb_global_table.default[0].name}"]
  }
}

resource "aws_iam_policy" "default" {
  count = length(var.regions) > 0 && var.policy_name != "" ? 1 : 0

  name = var.policy_name
  path = "/"

  description = "Policy used to manage DynamoDB table ${aws_dynamodb_global_table.default[0].name}"

  policy = data.aws_iam_policy_document.default[0].json
}
