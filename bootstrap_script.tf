resource aws_s3_bucket default {
  bucket_prefix = "emr-config-"
  acl           = "private"
}

resource aws_s3_bucket_object default {
  bucket = aws_s3_bucket.default.bucket
  key    = "get_auth_token.sh"
  source = "${path.module}/scripts/get_auth_token.sh"
  etag   = filemd5("${path.module}/scripts/get_auth_token.sh")
}

resource aws_s3_bucket_policy default {
  bucket = aws_s3_bucket.default.bucket
  policy = <<-EOF
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Action": "s3:GetObject",
          "Effect": "Allow",
          "Resource": "${aws_s3_bucket.default.arn}/${aws_s3_bucket_object.default.key}",
          "Principal": {
            "AWS": [
              "${aws_iam_role.instance-role.arn}"
            ]
          }
        },
        {
          "Action": [
            "s3:GetObject",
            "s3:PutObject"
          ],
          "Effect": "Allow",
          "Resource": "${aws_s3_bucket.default.arn}/config.json",
          "Principal": {
            "AWS": [
              "${aws_iam_role.instance-role.arn}"
            ]
          }
        }
      ]
    }
  EOF
}