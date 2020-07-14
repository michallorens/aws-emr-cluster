resource aws_iam_role autoscaling-role {
  name = "role-for-emr-autoscaling-${random_id.default.b64_url}"
  tags = var.tags

  assume_role_policy = <<-EOF
    {
      "Version": "2008-10-17",
      "Statement": [{
        "Action": "sts:AssumeRole",
        "Effect": "Allow",
        "Principal": {
          "Service": "elasticmapreduce.amazonaws.com"
        }
      }]
    }
  EOF
}

resource aws_iam_role_policy autoscaling-policy {
  name = "emr-autoscaling-policy-${random_id.default.b64_url}"
  role = aws_iam_role.autoscaling-role.id

  policy = <<-EOF
    {
      "Version": "2012-10-17",
      "Statement": [{
        "Effect": "Allow",
        "Resource": "*",
        "Action": [
          "cloudwatch:DescribeAlarms",
          "elasticmapreduce:ListInstanceGroups",
          "elasticmapreduce:ModifyInstanceGroups"
        ]
      }]
    }
  EOF
}