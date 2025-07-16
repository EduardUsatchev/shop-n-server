# provider.tf (improvement for prod/stage support)
provider "aws" {
  region = var.region

  # For LocalStack (testing/dev only)
  access_key = var.localstack ? "test" : null
  secret_key = var.localstack ? "test" : null

  # For real AWS: rely on environment variables or credentials file.
  # NEVER commit secrets!

  endpoints = var.localstack ? {
    sqs            = var.localstack_endpoint
    s3             = var.localstack_endpoint
    secretsmanager = var.localstack_endpoint
    rds            = var.localstack_endpoint
    ec2            = var.localstack_endpoint
    sts            = var.localstack_endpoint
  } : {}
  s3_use_path_style = var.localstack
}
