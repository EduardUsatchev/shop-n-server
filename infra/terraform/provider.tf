provider "aws" {
  region                      = var.region
  access_key                  = "test"
  secret_key                  = "test"

  endpoints {
    sqs            = var.localstack_endpoint
    s3             = var.localstack_endpoint
    secretsmanager = var.localstack_endpoint
    rds            = var.localstack_endpoint
    ec2            = var.localstack_endpoint
    sts            = var.localstack_endpoint
  }
  s3_use_path_style = true

}
