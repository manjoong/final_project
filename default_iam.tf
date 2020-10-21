resource "aws_iam_role" "WebAppRole" {
    name = "${var.userid}-WebAppRole"
    path = "/"
    
    assume_role_policy = <<-EOF
    {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Sid": "",
                "Effect": "Allow",
                "Principal": {
                    "Service": "ec2.amazonaws.com"
                },
                "Action": "sts:AssumeRole"
            }
        ]
    }
    EOF
}

resource "aws_iam_role_policy" "WebAppRolePolicy" {
    name = "${var.userid}-BackendRole"
    role = aws_iam_role.WebAppRole.id

    policy = <<-EOF
    {
        "Version": "2012-10-17",
        "Statement": [
        {
            "Action": [
                "autoscaling:Describe*",
                "autoscaling:EnterStandby",
                "autoscaling:ExitStandby",
                "autoscaling:UpdateAutoScalingGroup"
            ],
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Action": [
                "ec2:DescribeInstances",
                "ec2:DescribeInstanceStatus"
            ],
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Action": [
                "s3:Get*",
                "s3:List*"
            ],
            "Resource": [
                "arn:aws:s3:::skcc-cicd-workshop-${var.region}-${var.userid}-${data.aws_caller_identity.current.account_id}",
                "arn:aws:s3:::skcc-cicd-workshop-${var.region}-${var.userid}-${data.aws_caller_identity.current.account_id}/*",
                "arn:aws:s3:::codepipeline-*"
            ],
            "Effect": "Allow"
        }]
    }
    EOF
}
