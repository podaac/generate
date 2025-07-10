# Define roles so AWS Batch can execute jobs
resource "aws_iam_role" "batch_ecs_execution_role" {
  name = "${var.prefix}-batch-ecs-execution-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ecs-tasks.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "batch_ecs_execution_role_attach" {
  role       = aws_iam_role.batch_ecs_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# AWS Batch role and policy
resource "aws_iam_role" "aws_batch_service_role" {
  name = "${var.prefix}-batch-service-role"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "batch.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
  permissions_boundary = "arn:aws:iam::${local.account_id}:policy/NGAPShRoleBoundary"
}

resource "aws_iam_role_policy_attachment" "aws_batch_service_role_policy_attach" {
  role       = aws_iam_role.aws_batch_service_role.name
  policy_arn = aws_iam_policy.batch_service_role_policy.arn
}

resource "aws_iam_policy" "batch_service_role_policy" {
  name        = "${var.prefix}-batch-service-role-policy"
  description = "Provides access for the AWS Batch service to manage the required resources, including Amazon EC2 and Amazon ECS resources"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "ec2:DescribeAccountAttributes",
          "ec2:DescribeInstances",
          "ec2:DescribeInstanceAttribute",
          "ec2:DescribeSubnets",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeKeyPairs",
          "ec2:DescribeImages",
          "ec2:DescribeImageAttribute",
          "ec2:DescribeInstanceStatus",
          "ec2:DescribeVpcClassicLink",
          "ec2:DescribeLaunchTemplateVersions",
          "ec2:CreateLaunchTemplate",
          "ec2:DeleteLaunchTemplate",
          "ec2:TerminateInstances",
          "ec2:RunInstances",
          "autoscaling:DescribeAccountLimits",
          "autoscaling:DescribeAutoScalingGroups",
          "autoscaling:DescribeLaunchConfigurations",
          "autoscaling:DescribeAutoScalingInstances",
          "autoscaling:CreateLaunchConfiguration",
          "autoscaling:CreateAutoScalingGroup",
          "autoscaling:UpdateAutoScalingGroup",
          "autoscaling:SetDesiredCapacity",
          "autoscaling:DeleteLaunchConfiguration",
          "autoscaling:DeleteAutoScalingGroup",
          "autoscaling:CreateOrUpdateTags",
          "autoscaling:SuspendProcesses",
          "autoscaling:PutNotificationConfiguration",
          "autoscaling:TerminateInstanceInAutoScalingGroup",
          "ecs:DeleteCluster",
          "ecs:DescribeClusters",
          "ecs:DescribeContainerInstances",
          "ecs:DescribeTaskDefinition",
          "ecs:DescribeTasks",
          "ecs:ListAccountSettings",
          "ecs:ListClusters",
          "ecs:ListContainerInstances",
          "ecs:ListTaskDefinitionFamilies",
          "ecs:ListTaskDefinitions",
          "ecs:ListTasks",
          "ecs:CreateCluster",
          "ecs:DeleteCluster",
          "ecs:RegisterTaskDefinition",
          "ecs:DeregisterTaskDefinition",
          "ecs:RunTask",
          "ecs:StartTask",
          "ecs:StopTask",
          "ecs:UpdateContainerAgent",
          "ecs:DeregisterContainerInstance",
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups",
          "iam:GetInstanceProfile",
          "iam:GetRole"
        ],
        "Resource" : "*"
      },
      {
        "Effect" : "Allow",
        "Action" : "ecs:TagResource",
        "Resource" : [
          "arn:aws:ecs:*:*:task/*_Batch_*"
        ]
      },
      {
        "Effect" : "Allow",
        "Action" : "iam:PassRole",
        "Resource" : [
          "*"
        ],
        "Condition" : {
          "StringEquals" : {
            "iam:PassedToService" : [
              "ec2.amazonaws.com",
              "ecs-tasks.amazonaws.com"
            ]
          }
        }
      },
      {
        "Effect" : "Allow",
        "Action" : "iam:CreateServiceLinkedRole",
        "Resource" : "*",
        "Condition" : {
          "StringEquals" : {
            "iam:AWSServiceName" : [
              "autoscaling.amazonaws.com",
              "ecs.amazonaws.com"
            ]
          }
        }
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "ec2:CreateTags"
        ],
        "Resource" : [
          "*"
        ],
        "Condition" : {
          "StringEquals" : {
            "ec2:CreateAction" : "RunInstances"
          }
        }
      }
    ]
  })
}

# Amazon ECS role and policy
resource "aws_iam_instance_profile" "ecs_instance_profile" {
  name = "${var.prefix}-ecs-instance-role"
  role = aws_iam_role.ecs_instance_role.name
}

resource "aws_iam_role" "ecs_instance_role" {
  name = "${var.prefix}-ecs-instance-role"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : { "Service" : "ec2.amazonaws.com" },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
  permissions_boundary = "arn:aws:iam::${local.account_id}:policy/NGAPShRoleBoundary"
}

resource "aws_iam_role_policy_attachment" "ecs_role_ec2_policy_attach" {
  role       = aws_iam_role.ecs_instance_role.name
  policy_arn = aws_iam_policy.aws_ec2_container_service_for_ec2_role.arn
}

resource "aws_iam_policy" "aws_ec2_container_service_for_ec2_role" {
  name        = "${var.prefix}-aws-ec2-container-service-for-ec2-role"
  description = "Amazon EC2 Role policy for Amazon EC2 Container Service"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "ec2:DescribeTags",
          "ecs:CreateCluster",
          "ecs:DeregisterContainerInstance",
          "ecs:DiscoverPollEndpoint",
          "ecs:Poll",
          "ecs:RegisterContainerInstance",
          "ecs:StartTelemetrySession",
          "ecs:UpdateContainerInstancesState",
          "ecs:Submit*",
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        "Resource" : "*"
      }
    ]
  })
}

# AWS Batch job role
resource "aws_iam_role" "batch_job_role" {
  name = "${var.prefix}-batch-job-role"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "ecs-tasks.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
  permissions_boundary = "arn:aws:iam::${local.account_id}:policy/NGAPShRoleBoundary"
}

resource "aws_iam_role_policy_attachment" "batch_job_role_policy_attach" {
  role       = aws_iam_role.batch_job_role.name
  policy_arn = aws_iam_policy.batch_job_role_policy.arn
}

resource "aws_iam_policy" "batch_job_role_policy" {
  name        = "${var.prefix}-batch-job-policy"
  description = "Amazon EC2 Role policy for Amazon EC2 Container Service"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "logs:DescribeLogGroups"
        ],
        "Resource" : "*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "logs:CreateLogStream",
          "logs:DescribeLogStreams"
        ],
        "Resource" : [
          "${aws_cloudwatch_log_group.generate_cw_log_group_downloader_error.arn}:*",
          "${aws_cloudwatch_log_group.generate_cw_log_group_combiner_error.arn}:*",
          "${aws_cloudwatch_log_group.generate_cw_log_group_processor_error.arn}:*"
        ]
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "logs:PutLogEvents"
        ],
        "Resource" : [
          "arn:aws:logs:${var.aws_region}:${local.account_id}:log-group:${aws_cloudwatch_log_group.generate_cw_log_group_downloader_error.name}:log-stream:*",
          "arn:aws:logs:${var.aws_region}:${local.account_id}:log-group:${aws_cloudwatch_log_group.generate_cw_log_group_combiner_error.name}:log-stream:*",
          "arn:aws:logs:${var.aws_region}:${local.account_id}:log-group:${aws_cloudwatch_log_group.generate_cw_log_group_processor_error.name}:log-stream:*"
        ]
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "sns:ListTopics"
        ],
        "Resource" : "*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "sns:Publish"
        ],
        "Resource" : "${aws_sns_topic.aws_sns_topic_batch_job_failure.arn}"
      }
    ]
  })
}