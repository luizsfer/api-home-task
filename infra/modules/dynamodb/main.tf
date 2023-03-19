module "dynamodb_table" {
  source   = "terraform-aws-modules/dynamodb-table/aws"

  name     = var.dynamodb_table_name
  hash_key = "username"

  attributes = [
    {
      name = "username"
      type = "S"
    }
  ]
}
