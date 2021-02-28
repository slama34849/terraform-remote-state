provider "aws" {
  region = "us-east-2"
}  # Input Variable

data "aws_ami" "app_ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}

output "ami" {
    value = data.aws_ami.app_ami.id
}