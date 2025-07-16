variable "ami_id" {
  description = "AMI ID for EC2 instances"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.small"
  validation {
    condition     = contains(["t2.micro", "t3.small", "t3.medium"], var.instance_type)
    error_message = "Must be a valid instance type."
  }
}

variable "vpc_id" {
  description = "The VPC ID where instances are launched"
  type        = string
}

variable "public_subnets" {
  description = "List of public subnet IDs"
  type        = list(string)
}
