include(`foreach.m4')dnl
`# Autogenerated by tables.m4 DO NOT EDIT.'dnl
foreach(`REGION', (REGIONS), `

resource "aws_dynamodb_table" "REGION" {
  count    = contains(var.regions, "REGION") ? 1 : 0
  provider = aws.REGION

  name         = var.name
  hash_key     = "username"
  billing_mode = "PAY_PER_REQUEST"

  stream_enabled   = true
  stream_view_type = "NEW_AND_OLD_IMAGES"

  attribute {
    name = "username"
    type = "S"
  }
}')