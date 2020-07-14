resource aws_iam_role instance-role {
  name = "emr-instance-role-${random_id.default.b64_url}"
  tags = var.tags

  assume_role_policy = <<-EOF
    {
      "Version": "2008-10-17",
      "Statement": [{
        "Action": "sts:AssumeRole",
        "Effect": "Allow",
        "Principal": {
          "Service": "ec2.amazonaws.com"
        }
      }]
    }
  EOF
}

resource aws_iam_instance_profile default {
  name = "emr-instance-profile-${random_id.default.b64_url}"
  role = aws_iam_role.instance-role.name
}

resource aws_iam_role_policy iam_emr_profile_policy {
  name = "emr-instance-policy-${random_id.default.b64_url}"
  role = aws_iam_role.instance-role.id

  policy = <<-EOF
    {
      "Version": "2012-10-17",
      "Statement": [{
        "Effect": "Allow",
        "Resource": "*",
        "Action": [
          "cloudwatch:*",
          "dynamodb:*",
          "ec2:Describe*",
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:GetRepositoryPolicy",
          "ecr:DescribeRepositories",
          "ecr:ListImages",
          "ecr:DescribeImages",
          "ecr:BatchGetImage",
          "ecr:GetLifecyclePolicy",
          "ecr:GetLifecyclePolicyPreview",
          "ecr:ListTagsForResource",
          "ecr:DescribeImageScanFindings",
          "elasticmapreduce:Describe*",
          "elasticmapreduce:ListBootstrapActions",
          "elasticmapreduce:ListClusters",
          "elasticmapreduce:ListInstanceGroups",
          "elasticmapreduce:ListInstances",
          "elasticmapreduce:ListSteps",
          "kinesis:CreateStream",
          "kinesis:DeleteStream",
          "kinesis:DescribeStream",
          "kinesis:GetRecords",
          "kinesis:GetShardIterator",
          "kinesis:MergeShards",
          "kinesis:PutRecord",
          "kinesis:SplitShard",
          "rds:Describe*",
          "s3:*",
          "sdb:*",
          "sns:*",
          "sqs:*"
        ]
      }]
    }
  EOF
}