resource "aws_instance" "this" {
  count         = length(var.public_subnets)
  ami           = "ami-0c55b159cbfafe1f0" # Example: Ubuntu 22.04 LTS in eu-west-1, update as needed
  instance_type = "t3.small"
  subnet_id     = var.public_subnets[count.index]

  tags = {
    Name = "shopnserve-ec2-${count.index}"
  }
}
