variable "region" { default = "eu-west-1" }
variable "aws_access_key" { default = "test" }
variable "aws_secret_key" { default = "test" }
variable "localstack_endpoint" {
  default = "http://localhost:4566"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}
variable "enable_rds" {
  description = "If false, RDS is not provisioned (useful for LocalStack/CI)"
  type        = bool
  default     = true
}
variable "db_name" {
  description = "Database name for RDS (if enabled)"
  type        = string
  default     = "shopnserve"
}

variable "username" {
  description = "Master DB username for RDS (if enabled)"
  type        = string
  default     = "admin"
}
