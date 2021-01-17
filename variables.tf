variable "s3_key" {
  type        = string
  description = "S3 Key of the Source Artifact"
}

variable "s3_bucket" {
  type        = string
  description = "S3 Bucket w/ Lambda Artifact Resides in"
}

variable "handler" {
  type        = string
  description = "Java entrypoint for the function"
}

variable "runtime" {
  type    = string
  default = "java11"
}

variable "name" {
  type        = string
  description = "Unique name of the lambda function"
}

variable "policy_json" {
  type        = string
  description = "Policy to apply to the function"
}

variable "schedule_expression" {
  type        = string
  description = "Schedule CRON to run the function(UTC)"
}

variable "timeout" {
  type        = number
  description = "Timeout in sec of the function"
  default     = 60
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "environment_variables" {
  type    = map(string)
  default = {}
}

variable "memory_size" {
  type    = number
  default = 1024
}
