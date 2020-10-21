#
# ec2 autoscaling configuration
#
resource "aws_iam_instance_profile" "instance-profile" {
  name = "${var.userid}-instance-profile"
  role = aws_iam_role.WebAppRole.name
}

resource "aws_launch_configuration" "lc1" {
  name_prefix = "${var.userid}-autoscaling-instance-"
  iam_instance_profile = aws_iam_instance_profile.instance-profile.name

  image_id = var.ami-id
  instance_type = "t2.micro"
  key_name = aws_key_pair.public_key.key_name
  security_groups = [
    "${aws_security_group.sg1_ec2.id}",
    "${aws_default_security_group.sg1_default.id}",
  ]
  associate_public_ip_address = true
    
  lifecycle {
    create_before_destroy = true
  }
  user_data = <<EOF
    #!/bin/bash
    sudo yum update -y
    sudo yum install -y aws-cli
    sudo yum install -y git
    sudo yum install -y ruby
    cd /home/ec2-user/
    sudo wget https://aws-codedeploy-${var.region}.s3.amazonaws.com/latest/codedeploy-agent.noarch.rpm
    sudo yum -y install /home/ec2-user/codedeploy-agent.noarch.rpm
    sudo service codedeploy-agent start
	EOF
}