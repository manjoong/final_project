#
# autoscaling group creation
#
resource "aws_autoscaling_group" "asg1" {
  name = "${aws_launch_configuration.lc1.name}-asg1"

  min_size             = 1
  desired_capacity     = 2
  max_size             = 3

  health_check_type    = "ELB"

  launch_configuration = aws_launch_configuration.lc1.name

  enabled_metrics = [
    "GroupMinSize",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupTotalInstances"
  ]

  metrics_granularity="1Minute"

  vpc_zone_identifier  = [
    aws_subnet.subnet1.id,
    aws_subnet.subnet2.id
  ]

  # Required to redeploy without an outage.
  lifecycle {
    create_before_destroy = true
  }

  tag {
    key                 = "Name"
    value               = "${var.userid}-instance-autoscaling"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_attachment" "asg1-attachment" {
  autoscaling_group_name = aws_autoscaling_group.asg1.id
  alb_target_group_arn   = aws_alb_target_group.tg1.arn
}