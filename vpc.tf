#
# Key Pair Creation
#
resource "aws_key_pair" "public_key" {
  key_name   = "${var.userid}_public_key"
  public_key = file("~/.ssh/id_rsa.pub")
}
#
# provider creation
#
provider "aws" {
  region  = var.region
}

resource "aws_vpc" "vpc1" {
  cidr_block       = var.vpc1-cidr

  enable_dns_hostnames = true
  enable_dns_support =true
  instance_tenancy ="default"
  tags = {
    Name = "${var.userid}-vpc"
  }
}
