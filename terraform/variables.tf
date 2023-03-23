variable "app_name" {
  type        = string
  description = "Application name"
  default     = "generate"
}

variable "app_version" {
  type        = number
  description = "The application version number"
  default     = 0.1
}

variable "aws_region" {
  type        = string
  description = "AWS region to deploy to"
  default     = "us-west-2"
}

variable "default_tags" {
  type    = map(string)
  default = {}
}

variable "ecs_ami_id_ssm_name" {
  default     = "image_id_ecs_amz2"
  description = "Name of the SSM Parameter that contains the NGAP approved ECS AMI ID."
}

variable "environment" {
  type        = string
  description = "The environment in which to deploy to"
}

variable "instance_type" {
  type        = list(any)
  description = "List of instance types used by Batch to launch jobs"
  default     = ["c5.4xlarge", "c5.2xlarge", "c5.xlarge", "c5.large"]
}

variable "prefix" {
  type        = string
  description = "Prefix to add to all AWS resources as a unique identifier"
}

variable "profile" {
  type        = string
  description = "Named profile to build infrastructure with"
}

variable "sns_topic_email" {
  type        = string
  description = "Email to send SNS Topic messages to"
}