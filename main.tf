data aws_caller_identity default {}

data aws_region default {}

resource random_id default {
  byte_length = 16
}

module ecr-docker-image {
  source = "github.com/michallorens/aws-ecr-image?ref=v0.0.4"

  name = "pyspark_${random_id.default.hex}"
  path = "${path.module}/docker/pyspark"
}

resource aws_emr_cluster default {
  name             = "emr-cluster-${random_id.default.b64_url}"
  tags             = var.tags
  release_label    = var.release
  applications     = var.applications
  service_role     = aws_iam_role.service-role.arn
  autoscaling_role = aws_iam_role.autoscaling-role.arn

  termination_protection            = var.termination_protection
  keep_job_flow_alive_when_no_steps = var.on_when_idle

  ec2_attributes {
    instance_profile = aws_iam_instance_profile.default.arn
    subnet_id        = var.subnet_id
    key_name         = aws_key_pair.default.id

    additional_master_security_groups = aws_security_group.default.id
    additional_slave_security_groups  = aws_security_group.default.id
  }

  bootstrap_action {
    name = "emr-bootstrap-${random_id.default.b64_url}"
    path = "s3://${aws_s3_bucket_object.default.bucket}/${aws_s3_bucket_object.default.key}"
    args = [data.aws_region.default.name, module.ecr-docker-image.registry, aws_s3_bucket.default.bucket]
  }

  master_instance_group {
    name           = "emr-master-instance-group-${random_id.default.b64_url}"
    instance_type  = var.master.instance_type
    instance_count = var.master.high_availability ? 3 : 1
    bid_price      = var.master.bid_price != "" ? var.master.bid_price : ""
  }

  core_instance_group {
    name = "emr-core-instance-group-${random_id.default.b64_url}"
    instance_type = var.core.instance_type
    instance_count = var.core.min_instance_count
    bid_price = var.core.bid_price != "" ? var.core.bid_price : ""
    autoscaling_policy = <<-EOF
      {
        "Constraints": {
          "MinCapacity": ${var.core.min_instance_count},
          "MaxCapacity": ${var.core.max_instance_count}
        },
        "Rules": [
          {
            "Name": "emr-cluster-auto-scaling-${random_id.default.b64_url}",
            "Action": {
              "SimpleScalingPolicyConfiguration": {
                "AdjustmentType": "CHANGE_IN_CAPACITY",
                "ScalingAdjustment": 1,
                "CoolDown": 60
              }
            },
            "Trigger": {
              "CloudWatchAlarmDefinition": {
                "ComparisonOperator": "LESS_THAN",
                "EvaluationPeriods": 1,
                "MetricName": "YARNMemoryAvailablePercentage",
                "Namespace": "AWS/ElasticMapReduce",
                "Period": 60,
                "Statistic": "AVERAGE",
                "Threshold": 15.0,
                "Unit": "PERCENT"
              }
            }
          }
        ]
      }
    EOF
  }

  configurations_json = <<-EOF
    [
      {
        "Classification":"container-executor",
        "Properties": {},
        "Configurations": [
          {
            "Classification":"docker",
            "Properties": {
              "docker.privileged-containers.registries": "local,centos,${module.ecr-docker-image.registry}",
              "docker.trusted.registries": "local,centos,${module.ecr-docker-image.registry}"
            }
          }
        ]
      },
      {
        "Classification": "livy-conf",
        "Properties": {
          "livy.spark.master": "yarn",
          "livy.spark.deploy-mode": "cluster",
          "livy.server.session.timeout": "24h"
        }
      },
      {
        "Classification": "hive-site",
        "Properties": {
          "hive.execution.mode": "container"
        }
      },
      {
        "Classification": "spark-defaults",
        "Properties": {
          "spark.yarn.am.waitTime": "300s",
          "spark.executorEnv.YARN_CONTAINER_RUNTIME_TYPE": "docker",
          "spark.yarn.appMasterEnv.YARN_CONTAINER_RUNTIME_TYPE": "docker",
          "spark.executorEnv.YARN_CONTAINER_RUNTIME_DOCKER_CLIENT_CONFIG": "s3://${aws_s3_bucket.default.bucket}/config.json",
          "spark.yarn.appMasterEnv.YARN_CONTAINER_RUNTIME_DOCKER_CLIENT_CONFIG": "s3://${aws_s3_bucket.default.bucket}/config.json",
          "spark.executorEnv.YARN_CONTAINER_RUNTIME_DOCKER_IMAGE": "${module.ecr-docker-image.image}",
          "spark.yarn.appMasterEnv.YARN_CONTAINER_RUNTIME_DOCKER_IMAGE": "${module.ecr-docker-image.image}"
        }
      }
    ]
  EOF
}