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
    max_vcpus          = 128
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
  type         = "MANAGED"

  depends_on = [
    aws_iam_role.aws_batch_service_role,
    aws_iam_policy.batch_service_role_policy,
    aws_iam_role_policy_attachment.aws_batch_service_role_policy_attach
  ]

  lifecycle {
    create_before_destroy = true
  }
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
}

# Job Queue
resource "aws_batch_job_queue" "aqua" {
  name                  = "${var.prefix}-aqua"
  state                 = "ENABLED"
  priority              = 10
  compute_environment_order {
    order = 1
    compute_environment = aws_batch_compute_environment.generate_aqua.arn
  }
  scheduling_policy_arn = aws_batch_scheduling_policy.generate_aqua.arn
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
    max_vcpus          = 128
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
  type         = "MANAGED"

  depends_on = [
    aws_iam_role.aws_batch_service_role,
    aws_iam_policy.batch_service_role_policy,
    aws_iam_role_policy_attachment.aws_batch_service_role_policy_attach
  ]

  lifecycle {
    create_before_destroy = true
  }
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
}

# Job Queue
resource "aws_batch_job_queue" "terra" {
  name                  = "${var.prefix}-terra"
  state                 = "ENABLED"
  priority              = 10
  compute_environment_order {
    order = 1
    compute_environment = aws_batch_compute_environment.generate_terra.arn
  }
  scheduling_policy_arn = aws_batch_scheduling_policy.generate_terra.arn
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
    max_vcpus          = 128
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
  type         = "MANAGED"

  depends_on = [
    aws_iam_role.aws_batch_service_role,
    aws_iam_policy.batch_service_role_policy,
    aws_iam_role_policy_attachment.aws_batch_service_role_policy_attach
  ]

  lifecycle {
    create_before_destroy = true
  }
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
}

# Job Queue
resource "aws_batch_job_queue" "viirs" {
  name                  = "${var.prefix}-viirs"
  state                 = "ENABLED"
  priority              = 10
  compute_environment_order {
    order = 1
    compute_environment = aws_batch_compute_environment.generate_viirs.arn
  }
  scheduling_policy_arn = aws_batch_scheduling_policy.generate_viirs.arn
}

# JPSS1
# Compute Environment
resource "aws_batch_compute_environment" "generate_jpss1" {
  compute_environment_name = "${var.prefix}-jpss1"
  compute_resources {
    allocation_strategy = "BEST_FIT_PROGRESSIVE"
    ec2_configuration {
      image_id_override = data.aws_ssm_parameter.ecs_image_id.value
      image_type        = "ECS_AL2"
    }
    instance_role = aws_iam_instance_profile.ecs_instance_profile.arn
    instance_type = var.instance_type
    max_vcpus          = 128
    min_vcpus          = 0
    security_group_ids = data.aws_security_groups.vpc_default_sg.ids
    subnets            = data.aws_subnets.private_application_subnets.ids
    type               = "EC2"
    tags = {
      "Name" : "${var.prefix}-batch-jpss1-node"
    }
  }
  service_role = aws_iam_role.aws_batch_service_role.arn
  state        = "ENABLED"
  type         = "MANAGED"

  depends_on = [
    aws_iam_role.aws_batch_service_role,
    aws_iam_policy.batch_service_role_policy,
    aws_iam_role_policy_attachment.aws_batch_service_role_policy_attach
  ]

  lifecycle {
    create_before_destroy = true
  }
}

# Scheduling Policy
resource "aws_batch_scheduling_policy" "generate_jpss1" {
  name = "${var.prefix}-jpss1"
  fair_share_policy {
    share_distribution {
      share_identifier = "generatejpss1"
      weight_factor    = 1.0
    }
  }
}

# Job Queue
resource "aws_batch_job_queue" "jpss1" {
  name                  = "${var.prefix}-jpss1"
  state                 = "ENABLED"
  priority              = 10
  compute_environment_order {
    order = 1
    compute_environment = aws_batch_compute_environment.generate_jpss1.arn
  }
  scheduling_policy_arn = aws_batch_scheduling_policy.generate_jpss1.arn
}