resource "aws_cloudwatch_log_group" "log_group" {
  name              = var.log_group_name
  retention_in_days = var.retention_in_days
}

output "log_group_arn" {
  value = aws_cloudwatch_log_group.log_group.arn
}
