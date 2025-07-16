resource "aws_sqs_queue" "this" {
  name                       = var.queue_name
  visibility_timeout_seconds = var.visibility_timeout
  message_retention_seconds  = var.retention_seconds

  # Optionally add encryption, DLQ, etc.
}

variable "visibility_timeout" {
  description = "Visibility timeout for the SQS queue"
  type        = number
  default     = 30
}

variable "retention_seconds" {
  description = "Message retention in seconds"
  type        = number
  default     = 345600  # 4 days
}
