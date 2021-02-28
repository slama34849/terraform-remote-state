provider "aws" {
  region = var.region
}


data "aws_ami" "app_ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*gp2"]
  }
}


resource "aws_instance" "ec2_instance" {
  ami                         = data.aws_ami.app_ami.id
  instance_type               = var.instance_type
  key_name                    = var.key_name
  associate_public_ip_address = var.public_ip
  user_data                   = var.user_data
  count                       = var.instance_count
  tags = {
    Name = var.instance_tag
  }

}


output "public_ip" {
  value = aws_instance.ec2_instance[*].public_ip
}