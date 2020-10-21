#
# alb, alb target group, alb listener creation
#
resource "aws_alb" "alb1" {
    name = "${var.userid}-alb1"
    internal = false
    security_groups = [aws_security_group.sg1_ec2.id]
    subnets = [
        aws_subnet.subnet1.id,
        aws_subnet.subnet2.id
    ]
    tags = {
        Name = "${var.userid}-ALB1"
    }
    lifecycle { create_before_destroy = true }
}

resource "aws_alb_target_group" "tg1" {
    name = "${var.userid}-tg1"
    port = 80
    protocol = "HTTP"
    vpc_id = aws_vpc.vpc1.id
    health_check {
        interval = 30
        path = "/"
        healthy_threshold = 3
        unhealthy_threshold = 3
    }
    tags = { Name = "${var.userid}-tg1" }
}

resource "aws_alb_listener" "alb1-listener" {
    load_balancer_arn = aws_alb.alb1.arn
    port = "80"
    protocol = "HTTP"
    default_action {
        target_group_arn = aws_alb_target_group.tg1.arn
        type = "forward"
    }
}