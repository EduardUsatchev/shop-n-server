module "vpc" {
  source = "./modules/vpc"
  cidr = var.vpc_cidr
}

module "ec2" {
  source         = "./modules/ec2"
  vpc_id         = module.vpc.vpc_id
  public_subnets = module.vpc.public_subnets
}

module "s3" {
  source      = "./modules/s3"
  bucket_name = "shopnserve-ui"
}

module "sqs" {
  source     = "./modules/sqs"
  queue_name = "orders-queue"
}

module "rds" {
  source   = "./modules/rds"
  count    = var.enable_rds ? 1 : 0
  db_name  = var.db_name
  username = var.username
  password = random_password.db_password.result
}

module "iam" {
  source = "./modules/iam"
}
resource "random_password" "db_password" {
  length  = 16
  special = true
}



output "sqs_url"     { value = module.sqs.queue_url }
output "db_endpoint" {
  value = var.enable_rds ? module.rds[0].endpoint : "mocked"
}
