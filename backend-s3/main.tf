terraform {
  backend "s3" {
      bucket = "backend-terraform-iac"
      key = "httpserver/terraform.tfstate"   #the state file will be stored in the httpserver prefix/folder. It can be named anything.
      region = "us-east-1"
  }
}

provider "aws" {
	region = "us-east-1"
}

#create VPC
resource "aws_vpc" "my_terra_vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"
  tags = {
    Name = "terra-vpc"
  }
}

#Create Subnet
resource "aws_subnet" "my_terra_sub" {
  vpc_id     = aws_vpc.my_terra_vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1d"
  tags = {
    Name = "terra-subnet"
  }
}

# Create the Security Group
resource "aws_security_group" "terra_web_sg" {
  vpc_id       = aws_vpc.my_terra_vpc.id
  name         = "terra_web_sg"
  description  = "My VPC web Security Group"
  
  # allow ingress of port 80
  ingress {
    cidr_blocks = ["0.0.0.0/0"] 
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
  } 
  
  # allow egress of all ports
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
   Name = "terra_web_sg"
   Description = "My VPC Security Group"
}
} # end resource


#Create Ec2
resource "aws_instance" "my_instance" {
    ami = "ami-047a51fa27710816e"
    # availability_zone = "us-east-1d"
    subnet_id = aws_subnet.my_terra_sub.id
    instance_type = "t2.micro"
    key_name = "xxxxxxxx"
    # user_data = "${file("install_apache.sh")}"
    associate_public_ip_address = "true"
    security_groups = ["${aws_security_group.terra_web_sg.id}"]
    tags = {
        Name = "terra-instance"
    }
}

# Create the Internet Gateway
resource "aws_internet_gateway" "terra_igw" {
 vpc_id = aws_vpc.my_terra_vpc.id
 tags = {
        Name = "My VPC Internet Gateway"
}
} # end resource

# Create the Route Table
resource "aws_route_table" "terra_route_table" {
 vpc_id = aws_vpc.my_terra_vpc.id
 tags = {
        Name = "My VPC Route Table"
}
} # end resource

# Create the Internet Access
resource "aws_route" "terra_internet_access" {
  route_table_id         = aws_route_table.terra_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.terra_igw.id
} # end resource


# Associate the Route Table with the Subnet
resource "aws_route_table_association" "terra_sub_association" {
  subnet_id      = aws_subnet.my_terra_sub.id
  route_table_id = aws_route_table.terra_route_table.id
} # end resource


#I came accross a prblem with instance not starting due to sg not detecting in the VPC. I found the solution here,
#https://github.com/hashicorp/terraform/issues/575