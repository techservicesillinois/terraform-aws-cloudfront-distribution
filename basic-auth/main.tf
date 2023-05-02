# https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/globaltables.V2.html

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

locals {
  replica_regions = (length(var.regions) == 1 && var.regions[0] == "*") ? [for region in local.known_regions : region if region != data.aws_region.current.name] : [for region in local.known_regions : region if contains(var.regions, region) && region != data.aws_region.current.name]
}

resource "aws_dynamodb_table" "default" {
  count            = (length(var.regions) != 0) ? 1 : 0
  name             = var.name
  hash_key         = "username"
  billing_mode     = "PAY_PER_REQUEST"
  stream_enabled   = true
  stream_view_type = "NEW_AND_OLD_IMAGES"
  tags             = var.tags

  attribute {
    name = "username"
    type = "S"
  }

  dynamic "replica" {
    for_each = toset(local.replica_regions)

    content {
      propagate_tags = true
      region_name    = replica.value
    }
  }
}
