variable subnet_id {
  type        = string
  description = "ID of the subnet in which the cluster should be provisioned"
}

variable vpc_id {
  type        = string
  description = "ID of the VPC in which the cluster should be provisioned"
}

variable release {
  type        = string
  description = "Amazon EMR release version"
  default     = "emr-6.0.0"
}

variable applications {
  type        = list(string)
  description = "List of applications to deploy in the cluster"
  default     = ["Livy", "Spark"]
}

variable termination_protection {
  type        = bool
  description = "Enable cluster termination protection"
  default     = false
}

variable on_when_idle {
  type        = bool
  description = "Keep cluster alive when idle"
  default     = true
}

variable master_instance_type {
  type        = string
  description = "EC2 instance type for master nodes"
  default     = "m4.large"
}

variable cidr_blocks {
  type        = list(string)
  description = "CIDR blocks to grant access to cluster nodes"
  default     = ["10.0.0.0/8"]
}

variable master {
  type        = object({
    instance_type     = string
    high_availability = bool
    bid_price         = string
  })
  default = {
    instance_type     = "m5a.xlarge"
    high_availability = false
    bid_price         = ""
  }
}

variable core {
  type        = object({
    instance_type      = string
    min_instance_count = number
    max_instance_count = number
    bid_price          = string
  })
  default = {
    instance_type      = "c5.xlarge"
    min_instance_count = 1
    max_instance_count = 8
    bid_price          = ""
  }
}

variable tags {
  type        = map(any)
  description = "Tags to be applied to all created AWS resources"
  default     = {}
}