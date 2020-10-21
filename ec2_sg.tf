#
# ec2 security group creation
#
resource "aws_security_group" "sg1_ec2" {
  name        = "allow_http_ssh"
  description = "Allow HTTP/SSH inbound connections"
  vpc_id = aws_vpc.vpc1.id

  //allow http 80 port from alb
  ingress { 
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  //allow ssh 22 port from my_ip(cloud9)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.cloud9-cidr]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Allow HTTP/SSH Security Group"
  }
}