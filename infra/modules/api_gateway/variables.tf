variable "cloudwatch_log_group_arn" {
  type        = string
  description = "The ARN of the CloudWatch log group to which the access logs are sent."
}

variable "lambda_integration_uri" {
  type        = string
  description = "The URI of the Lambda function to invoke."
}