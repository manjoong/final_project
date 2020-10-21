resource "aws_subnet" "subnet1" {
  vpc_id            = aws_vpc.vpc1.id
  availability_zone = var.az1
  cidr_block        = var.subnet1-cidr

  tags  = {
    Name = "${var.userid}-subnet1"
  }
}

resource "aws_subnet" "subnet2" {
  vpc_id            = aws_vpc.vpc1.id
  availability_zone = var.az2
  cidr_block        = var.subnet2-cidr

  tags  = {
    Name = "${var.userid}-subnet2"
  }
}