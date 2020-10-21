
resource "aws_codecommit_repository" "WebAppRepo" {
  repository_name = "WebAppRepo"
  description     = "${var.userid}-WebApp-Repository"

  tags = {
    Name        = "${var.userid}-WebAppRepo"
    Creator     = var.userid
  }
}

resource "aws_codebuild_project" "devops-webapp-project" {
  name          = "${var.userid}-devops-webapp-project"
  description   = "test_codebuild_project"
  build_timeout = "5"
  service_role  = aws_iam_role.BuildTrustRole.arn

  artifacts {
    type = "S3"
    location = aws_s3_bucket.S3Bucket.bucket
    packaging = "ZIP"
    name = "WebAppOutputArtifact.zip"
  }

  environment {
    type  = "LINUX_CONTAINER"
    image = "aws/codebuild/java:openjdk-8"
    compute_type = "BUILD_GENERAL1_SMALL"
  }

  source {
    type            = "CODECOMMIT"
    location        = "https://git-codecommit.${var.region}.amazonaws.com/v1/repos/WebAppRepo"
  }

  tags = {
    Name        = "${var.userid}-devops-webapp-project"
    Environment = "Test"
  }
}

resource "aws_codedeploy_app" "CodedeployApp" {
  compute_platform = "Server"
  name             = "${var.userid}-DevOps-WebApp"
}

resource "aws_codedeploy_deployment_group" "CodedeployDeploymentGroup-Dev" {
  app_name              = aws_codedeploy_app.CodedeployApp.name
  deployment_group_name = "${var.userid}-CodedeployDeploymentGroup-Dev"
  service_role_arn      = aws_iam_role.DeployTrustRole.arn
  deployment_config_name = "CodeDeployDefault.OneAtATime"
  #deployment_config_name = "CodeDeployDefault.AllAtOnce"

  load_balancer_info {
    elb_info {
      name = aws_alb.alb1.name
    }
  }
  
  #ec2_tag_filter {
  #   key   = "Name"
  #   type  = "KEY_AND_VALUE"
  #   value = "${var.userid}-web-autoscaling-80"
  #}
  
  autoscaling_groups = [aws_autoscaling_group.asg1.name]
}

resource "aws_codepipeline" "CodePipeline" {
  name     = "${var.userid}-CodePipeline"
  role_arn = aws_iam_role.PipelineTrustRole.arn

  artifact_store {
    location = aws_s3_bucket.S3Bucket.bucket
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeCommit"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        RepositoryName   = "WebAppRepo"
        BranchName = "master"
        PollForSourceChanges = "false"
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]
      version          = "1"

      configuration = {
        ProjectName = "${var.userid}-devops-webapp-project"
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "CodeDeploy"
      input_artifacts = ["build_output"]
      version         = "1"

      configuration = {
        ApplicationName = "${var.userid}-DevOps-WebApp"
        DeploymentGroupName = "${var.userid}-CodedeployDeploymentGroup-Dev"
      }
    }
  }
}


resource "aws_iam_role" "BuildTrustRole" {
    name = "${var.userid}-BuildTrustRole"
    path = "/"
    
    assume_role_policy = <<-EOF
    {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Sid": "1",
                "Effect": "Allow",
                "Principal": {
                    "Service": [
                        "codebuild.amazonaws.com"
                    ]
                },
                "Action": "sts:AssumeRole"
            }
        ]
    }
    EOF
    
    tags = {
        tag-key = "${var.userid}_BuildTrustRole"
    }
}

resource "aws_iam_role_policy" "CodeBuildRolePolicy" {
    name = "${var.userid}-CodeBuildRolePolicy"
    role = aws_iam_role.BuildTrustRole.id

    policy = <<-EOF
    {
      "Version": "2012-10-17",
          "Statement": [
            {
              "Sid": "CloudWatchLogsPolicy",
              "Effect": "Allow",
              "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents"
              ],
              "Resource": [
                "*"
              ]
            },
            {
              "Sid": "CodeCommitPolicy",
              "Effect": "Allow",
              "Action": [
                "codecommit:GitPull"
              ],
              "Resource": [
                "*"
              ]
            },
            {
              "Sid": "S3GetObjectPolicy",
              "Effect": "Allow",
              "Action": [
                "s3:GetObject",
                "s3:GetObjectVersion"
              ],
              "Resource": [
                "*"
              ]
            },
            {
              "Sid": "S3PutObjectPolicy",
              "Effect": "Allow",
              "Action": [
                "s3:PutObject"
              ],
              "Resource": [
                "*"
              ]
            },
            {
              "Sid": "OtherPolicies",
              "Effect": "Allow",
              "Action": [
                "ssm:GetParameters",
                "ecr:*"
              ],
              "Resource": [
                "*"
              ]
            }
          ]
    }
    EOF
}

#
# Deploy Role Creation
#
resource "aws_iam_role" "DeployTrustRole" {
    name = "${var.userid}-DeployTrustRole"
    path = "/"
    
    assume_role_policy = <<-EOF
    {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Sid" : "",
                "Effect" : "Allow",
                "Principal" : {
                    "Service": [
                        "codedeploy.amazonaws.com"
                    ]
                },
                "Action" : "sts:AssumeRole"
            }
        ]
    }
    EOF
}

resource "aws_iam_role_policy_attachment" "role_policy_attach_AWSCodeDeployRole" {
  role       = aws_iam_role.DeployTrustRole.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole"
}

#
# Pipeline Role Creation
#
resource "aws_iam_role" "PipelineTrustRole" {
    name = "${var.userid}-PipelineTrustRole"
    path = "/"
    
    assume_role_policy = <<-EOF
    {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Sid": "1",
                "Effect": "Allow",
                "Principal": {
                    "Service": [
                        "codepipeline.amazonaws.com"
                    ]
                },
                "Action": "sts:AssumeRole"
            }
        ]
    }
    EOF
}

resource "aws_iam_role_policy" "CodePipelineRolePolicy" {
    name = "${var.userid}-CodePipelineRolePolicy"
    role = aws_iam_role.PipelineTrustRole.id

    policy = <<-EOF
    {
        "Version": "2012-10-17",
        "Statement": [
        {
            "Action": [
                "s3:*"
            ],
            "Resource": ["*"],
            "Effect": "Allow"
        },
        {
            "Action": [
                "codecommit:GetBranch",
                "codecommit:GetCommit",
                "codecommit:UploadArchive",
                "codecommit:GetUploadArchiveStatus",
                "codecommit:CancelUploadArchive"
            ],
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Action": [
                "codepipeline:*",
                "iam:ListRoles",
                "iam:PassRole",
                "codedeploy:CreateDeployment",
                "codedeploy:GetApplicationRevision",
                "codedeploy:GetDeployment",
                "codedeploy:GetDeploymentConfig",
                "codedeploy:RegisterApplicationRevision",
                "lambda:*",
                "sns:*",
                "ecs:*",
                "ecr:*"
            ],
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Action": [
                "codebuild:StartBuild",
                "codebuild:StopBuild",
                "codebuild:BatchGet*",
                "codebuild:Get*",
                "codebuild:List*",
                "codecommit:GetBranch",
                "codecommit:GetCommit",
                "codecommit:GetRepository",
                "codecommit:ListBranches",
                "s3:GetBucketLocation",
                "s3:ListAllMyBuckets"
            ],
            "Effect": "Allow",
            "Resource": "*"
        },
        {
            "Action": [
                "logs:GetLogEvents"
            ],
            "Effect": "Allow",
            "Resource": "arn:aws:logs:*:*:log-group:/aws/codebuild/*:log-stream:*"
        }]
    }
    EOF
}
#
# Lambda Role Creation
#
resource "aws_iam_role" "CodePipelineLambdaExecRole" {
    name = "${var.userid}-CodePipelineLambdaExecRole"
    path = "/"
    
    assume_role_policy = <<-EOF
    {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Sid": "1",
                "Effect": "Allow",
                "Principal": {
                    "Service": [
                        "lambda.amazonaws.com"
                    ]
                },
                "Action": "sts:AssumeRole"
            }
        ]
    }
    EOF
}

resource "aws_iam_role_policy" "CodePipelineLambdaExecPolicy" {
    name = "${var.userid}-CodePipelineLambdaExecPolicy"
    role = aws_iam_role.CodePipelineLambdaExecRole.id

    policy = <<-EOF
    {
        "Version": "2012-10-17",
        "Statement": [
        {
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Effect": "Allow",
            "Resource": "arn:aws:logs:*:*:*"
        },
        {
            "Action": [
                "codepipeline:PutJobSuccessResult",
                "codepipeline:PutJobFailureResult"
            ],
            "Effect": "Allow",
            "Resource": "*"
        }]
    }
    EOF
}


resource "aws_iam_role_policy_attachment" "role_policy_attach_AWSCodeDeployReadOnlyAccess" {
  role       = aws_iam_role.WebAppRole.name
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeDeployReadOnlyAccess"
}
resource "aws_iam_role_policy_attachment" "role_policy_attach_AmazonEC2ReadOnlyAccess" {
  role       = aws_iam_role.WebAppRole.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess"
}