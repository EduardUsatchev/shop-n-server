# infra/terraform/backend-s3.tf

terraform {
  backend "s3" {
    bucket         = "shop-n-server-terraform-state"   # Replace with your bucket name
    key            = "prod/terraform.tfstate"
    region         = "us-east-1"                       # Your AWS region
    dynamodb_table = "shop-n-server-terraform-lock"    # DynamoDB table for state locking
    encrypt        = true
  }
}
