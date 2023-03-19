variable "lambda_function_name" {
  type        = string
  description = "Name of the Lambda function"
}

variable "lambda_handler" {
  type        = string
  description = "Handler of the Lambda function"
}

variable "lambda_runtime" {
  type        = string
  description = "Runtime of the Lambda function"
}

variable "lambda_s3_bucket" {
  type        = string
  description = "S3 bucket where the Lambda function code is stored"
}

variable "lambda_s3_key" {
  type        = string
  description = "S3 key for the Lambda function code"
}

variable "lambda_role_name" {
  type        = string
  description = "Name of the IAM role for the Lambda function"
}

variable "environment_variables" {
  type        = map(string)
  description = "Environment variables for the Lambda function"
  default     = {}
}

variable "lambda_timeout" {
  type    = number
  default = 60
}

variable "api_gateway_arn" {
  type        = string
  description = "Name of the IAM role for the Lambda function"
}

variable "source_code_hash" {
  type        = string
  description = "The base64-encoded SHA256 hash of the package file specified with filename. Used only for versioned objects. Conflicts with s3_key"
  default     = ""
}

variable "dynamodb_table_arn" {
  type        = string
  description = "ARN of the DynamoDB table"
}
