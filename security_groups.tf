data aws_subnet default {
  id = var.subnet_id
}

resource aws_security_group default {
  name   = "emr-security-group-${random_id.default.b64_url}"
  tags   = var.tags
  vpc_id = var.vpc_id

  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = concat([data.aws_subnet.default.cidr_block], var.cidr_blocks)
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }
}