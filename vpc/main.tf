provider "aws" {
  region = var.region
}


# Fetch information about available availability zones
data "aws_availability_zones" "available" {}

# Create Virtual Private Cloud (VPC) with four availability zones
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "MainVPC"
  }
}

# Create subnets in each availability zone
resource "aws_subnet" "subnet" {
  count             = 4
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.${count.index}.0/24"
  availability_zone = element(data.aws_availability_zones.available.names, count.index)
}

# Create VMs in each availability zone with t2.micro instances
resource "aws_instance" "vm" {
  count         = 8
  ami           = var.ami_id
  instance_type = "t2.micro"
  subnet_id     = element(aws_subnet.subnet[*].id, count.index % length(aws_subnet.subnet[*].id))
}


# Create AWS Key Management Service (KMS) key for encryption
resource "aws_kms_key" "encryption_key" {
  description             = "Encryption key for sensitive data"
  enable_key_rotation     = true
  deletion_window_in_days = 7
}

# Add any additional configurations as needed

# Example of how to use availability zones information
output "available_zones" {
  value = data.aws_availability_zones.available.names
}
