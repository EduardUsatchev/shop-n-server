variable "vpc_id" {
  description = "The VPC ID where instances are launched"
  type        = string
}

variable "public_subnets" {
  description = "List of public subnet IDs"
  type        = list(string)
}
