variable "log_group_name" {
  type        = string
  description = "Name of the CloudWatch Log Group"
}

variable "retention_in_days" {
  type        = number
  description = "Number of days to retain log events in the CloudWatch Log Group"
  default     = 7
}
