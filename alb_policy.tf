#
#  autoscaling policy by ALB Request Count Per Target
#
resource "aws_autoscaling_policy" "auto-scaling-policy" {
  name                      = "${var.userid}-instance-tracking-policy"
  policy_type               = "TargetTrackingScaling"
  autoscaling_group_name    = aws_autoscaling_group.asg1.name
  estimated_instance_warmup = 200

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ALBRequestCountPerTarget"
      resource_label = "${aws_alb.alb1.arn_suffix}/${aws_alb_target_group.tg1.arn_suffix}"
    }
    
    target_value = "1" #ALBRequestCountPerTarget Request 1
  }
}