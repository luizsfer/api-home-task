locals {
  dynamodb_table_name = "users"

  lambda_zip = "${path.module}/../app/lambda.zip"
}

resource "null_resource" "upload_lambda_zip" {

  triggers = {
    zip_md5 = filemd5("${path.module}/../app/lambda.zip")
  }

  provisioner "local-exec" {
    command = "aws s3 cp ${local.lambda_zip} s3://${module.s3_bucket.bucket_id}/lambda.zip"
  }
}

module "dynamodb_table" {
  source              = "./modules/dynamodb"
  dynamodb_table_name = local.dynamodb_table_name
}

module "s3_bucket" {
  source      = "./modules/s3_bucket"
  bucket_name = "luiz-ferreira-test-lambda-bucket"
}

module "cloudwatch_log_group" {
  source         = "./modules/cloudwatch"
  log_group_name = "api-lambda"
}

module "api_gateway" {
  source                   = "./modules/api_gateway"
  cloudwatch_log_group_arn = module.cloudwatch_log_group.cloudwatch_log_group_arn
  lambda_integration_uri   = module.lambda.lambda_function_arn
}

module "lambda" {
  source               = "./modules/lambda"
  lambda_function_name = "api-lambda"
  lambda_s3_bucket     = module.s3_bucket.bucket_id
  lambda_s3_key        = "lambda.zip"
  lambda_handler       = "app.handler"
  lambda_runtime       = "python3.8"
  lambda_role_name     = "api-lambda-role"
  lambda_timeout       = 30
  environment_variables = {
    DYNAMODB_TABLE_NAME = local.dynamodb_table_name
    LOG_GROUP_NAME      = module.cloudwatch_log_group.cloudwatch_log_group_name
    BASE_PATH           = module.api_gateway.stage_name
  }
  dynamodb_table_arn = module.dynamodb_table.dynamodb_table_arn
  api_gateway_arn    = module.api_gateway.execution_arn_get
  depends_on         = [module.s3_bucket, null_resource.upload_lambda_zip]
}