output "queue_url" {
  description = "The URL of the SQS queue"
  value       = aws_sqs_queue.this.url
}
