# Compute Environment Launch Template
resource "aws_launch_template" "aws_batch_ce_lt" {
  name = "${var.prefix}-batch-compute-environment"
  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size           = 30
      delete_on_termination = true
      encrypted             = true
      volume_type           = "gp2"
    }
  }
  user_data              = filebase64("user-data")
  update_default_version = "true"
}

# MODIS Aqua
# Compute Environment
resource "aws_batch_compute_environment" "generate_aqua" {
  compute_environment_name = "${var.prefix}-aqua"
  compute_resources {
    allocation_strategy = "BEST_FIT_PROGRESSIVE"
    ec2_configuration {
      image_id_override = data.aws_ssm_parameter.ecs_image_id.value
      image_type        = "ECS_AL2"
    }
    instance_role = aws_iam_instance_profile.ecs_instance_profile.arn
    instance_type = var.instance_type
    launch_template {
      launch_template_id = aws_launch_template.aws_batch_ce_lt.id
      version            = aws_launch_template.aws_batch_ce_lt.latest_version
    }
    max_vcpus          = 32
    min_vcpus          = 0
    security_group_ids = data.aws_security_groups.vpc_default_sg.ids
    subnets            = data.aws_subnets.private_application_subnets.ids
    type               = "EC2"
    tags = {
      "Name" : "${var.prefix}-batch-aqua-node"
    }
  }
  service_role = aws_iam_role.aws_batch_service_role.arn
  state        = "ENABLED"
  tags         = local.default_tags
  type         = "MANAGED"

  provisioner "local-exec" {
    command = "aws ecs --profile ${var.profile} update-cluster-settings --cluster ${trimprefix(aws_batch_compute_environment.generate_aqua.ecs_cluster_arn, "arn:aws:ecs:${var.aws_region}:${local.account_id}:cluster/")} --settings name=containerInsights,value=enabled"
  }
  depends_on = [
    aws_iam_role.aws_batch_service_role
  ]
}

# Scheduling Policy
resource "aws_batch_scheduling_policy" "generate_aqua" {
  name = "${var.prefix}-aqua"
  fair_share_policy {
    share_distribution {
      share_identifier = "generateaqua"
      weight_factor    = 1.0
    }
  }
  tags = local.default_tags
}

# Job Queue
resource "aws_batch_job_queue" "aqua" {
  name                  = "${var.prefix}-aqua"
  state                 = "ENABLED"
  priority              = 10
  compute_environments  = [aws_batch_compute_environment.generate_aqua.arn]
  scheduling_policy_arn = aws_batch_scheduling_policy.generate_aqua.arn
  tags                  = local.default_tags
}

# MODIS Terra
# Compute Environment
resource "aws_batch_compute_environment" "generate_terra" {
  compute_environment_name = "${var.prefix}-terra"
  compute_resources {
    allocation_strategy = "BEST_FIT_PROGRESSIVE"
    ec2_configuration {
      image_id_override = data.aws_ssm_parameter.ecs_image_id.value
      image_type        = "ECS_AL2"
    }
    instance_role = aws_iam_instance_profile.ecs_instance_profile.arn
    instance_type = var.instance_type
    launch_template {
      launch_template_id = aws_launch_template.aws_batch_ce_lt.id
      version            = aws_launch_template.aws_batch_ce_lt.latest_version
    }
    max_vcpus          = 32
    min_vcpus          = 0
    security_group_ids = data.aws_security_groups.vpc_default_sg.ids
    subnets            = data.aws_subnets.private_application_subnets.ids
    type               = "EC2"
    tags = {
      "Name" : "${var.prefix}-batch-terra-node"
    }
  }
  service_role = aws_iam_role.aws_batch_service_role.arn
  state        = "ENABLED"
  tags         = local.default_tags
  type         = "MANAGED"

  provisioner "local-exec" {
    command = "aws ecs --profile ${var.profile} update-cluster-settings --cluster ${trimprefix(aws_batch_compute_environment.generate_terra.ecs_cluster_arn, "arn:aws:ecs:${var.aws_region}:${local.account_id}:cluster/")} --settings name=containerInsights,value=enabled"
  }
  depends_on = [
    aws_iam_role.aws_batch_service_role
  ]
}

# Scheduling Policy
resource "aws_batch_scheduling_policy" "generate_terra" {
  name = "${var.prefix}-terra"
  fair_share_policy {
    share_distribution {
      share_identifier = "generateterra"
      weight_factor    = 1.0
    }
  }
  tags = local.default_tags
}

# Job Queue
resource "aws_batch_job_queue" "terra" {
  name                  = "${var.prefix}-terra"
  state                 = "ENABLED"
  priority              = 10
  compute_environments  = [aws_batch_compute_environment.generate_terra.arn]
  scheduling_policy_arn = aws_batch_scheduling_policy.generate_terra.arn
  tags                  = local.default_tags
}

# VIIRS
# Compute Environment
resource "aws_batch_compute_environment" "generate_viirs" {
  compute_environment_name = "${var.prefix}-viirs"
  compute_resources {
    allocation_strategy = "BEST_FIT_PROGRESSIVE"
    ec2_configuration {
      image_id_override = data.aws_ssm_parameter.ecs_image_id.value
      image_type        = "ECS_AL2"
    }
    instance_role = aws_iam_instance_profile.ecs_instance_profile.arn
    instance_type = var.instance_type
    launch_template {
      launch_template_id = aws_launch_template.aws_batch_ce_lt.id
      version            = aws_launch_template.aws_batch_ce_lt.latest_version
    }
    max_vcpus          = 32
    min_vcpus          = 0
    security_group_ids = data.aws_security_groups.vpc_default_sg.ids
    subnets            = data.aws_subnets.private_application_subnets.ids
    type               = "EC2"
    tags = {
      "Name" : "${var.prefix}-batch-viirs-node"
    }
  }
  service_role = aws_iam_role.aws_batch_service_role.arn
  state        = "ENABLED"
  tags         = local.default_tags
  type         = "MANAGED"

  provisioner "local-exec" {
    command = "aws ecs --profile ${var.profile} update-cluster-settings --cluster ${trimprefix(aws_batch_compute_environment.generate_viirs.ecs_cluster_arn, "arn:aws:ecs:${var.aws_region}:${local.account_id}:cluster/")} --settings name=containerInsights,value=enabled"
  }
  depends_on = [
    aws_iam_role.aws_batch_service_role
  ]
}

# Scheduling Policy
resource "aws_batch_scheduling_policy" "generate_viirs" {
  name = "${var.prefix}-viirs"
  fair_share_policy {
    share_distribution {
      share_identifier = "generateviirs"
      weight_factor    = 1.0
    }
  }
  tags = local.default_tags
}

# Job Queue
resource "aws_batch_job_queue" "viirs" {
  name                  = "${var.prefix}-viirs"
  state                 = "ENABLED"
  priority              = 10
  compute_environments  = [aws_batch_compute_environment.generate_viirs.arn]
  scheduling_policy_arn = aws_batch_scheduling_policy.generate_viirs.arn
  tags                  = local.default_tags
}