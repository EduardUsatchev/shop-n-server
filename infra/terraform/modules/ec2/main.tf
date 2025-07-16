resource "aws_instance" "this" {
  count         = length(var.public_subnets)
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = var.public_subnets[count.index]

  tags = {
    Name = "shopnserve-ec2-${count.index}"
  }
}
