# MODIS Aqua
# Fargate Compute Environment
resource "aws_batch_compute_environment" "generate_aqua_fargate" {
  compute_environment_name = "${var.prefix}-aqua-fargate"
  compute_resources {
    type               = "FARGATE"
    max_vcpus          = 128
    subnets            = data.aws_subnets.private_application_subnets.ids
    security_group_ids = data.aws_security_groups.vpc_default_sg.ids
    # assign_public_ip = true
  }
  type         = "MANAGED"
  state        = "ENABLED"
  service_role = aws_iam_role.aws_batch_service_role.arn

  depends_on = [
    aws_iam_role.aws_batch_service_role,
    aws_iam_policy.batch_service_role_policy,
    aws_iam_role_policy_attachment.aws_batch_service_role_policy_attach
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
}

# Job Queue
resource "aws_batch_job_queue" "aqua" {
  name     = "${var.prefix}-aqua"
  state    = "ENABLED"
  priority = 10
  compute_environment_order {
    order               = 1
    compute_environment = aws_batch_compute_environment.generate_aqua_fargate.arn
  }
  scheduling_policy_arn = aws_batch_scheduling_policy.generate_aqua.arn
}

# MODIS Terra
# Fargate Compute Environment
resource "aws_batch_compute_environment" "generate_terra_fargate" {
  compute_environment_name = "${var.prefix}-terra-fargate"
  compute_resources {
    type               = "FARGATE"
    max_vcpus          = 128
    subnets            = data.aws_subnets.private_application_subnets.ids
    security_group_ids = data.aws_security_groups.vpc_default_sg.ids
    # assign_public_ip = true
  }
  type         = "MANAGED"
  state        = "ENABLED"
  service_role = aws_iam_role.aws_batch_service_role.arn

  depends_on = [
    aws_iam_role.aws_batch_service_role,
    aws_iam_policy.batch_service_role_policy,
    aws_iam_role_policy_attachment.aws_batch_service_role_policy_attach
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
}

# Job Queue
resource "aws_batch_job_queue" "terra" {
  name     = "${var.prefix}-terra"
  state    = "ENABLED"
  priority = 10
  compute_environment_order {
    order               = 1
    compute_environment = aws_batch_compute_environment.generate_terra_fargate.arn
  }
  scheduling_policy_arn = aws_batch_scheduling_policy.generate_terra.arn
}

# VIIRS
# Fargate Compute Environment
resource "aws_batch_compute_environment" "generate_viirs_fargate" {
  compute_environment_name = "${var.prefix}-viirs-fargate"
  compute_resources {
    type               = "FARGATE"
    max_vcpus          = 128
    subnets            = data.aws_subnets.private_application_subnets.ids
    security_group_ids = data.aws_security_groups.vpc_default_sg.ids
    # assign_public_ip = true
  }
  type         = "MANAGED"
  state        = "ENABLED"
  service_role = aws_iam_role.aws_batch_service_role.arn

  depends_on = [
    aws_iam_role.aws_batch_service_role,
    aws_iam_policy.batch_service_role_policy,
    aws_iam_role_policy_attachment.aws_batch_service_role_policy_attach
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
}

# Job Queue
resource "aws_batch_job_queue" "viirs" {
  name     = "${var.prefix}-viirs"
  state    = "ENABLED"
  priority = 10
  compute_environment_order {
    order               = 1
    compute_environment = aws_batch_compute_environment.generate_viirs_fargate.arn
  }
  scheduling_policy_arn = aws_batch_scheduling_policy.generate_viirs.arn
}

# JPSS1
# Fargate Compute Environment
resource "aws_batch_compute_environment" "generate_jpss1_fargate" {
  compute_environment_name = "${var.prefix}-jpss1-fargate"
  compute_resources {
    type               = "FARGATE"
    max_vcpus          = 128
    subnets            = data.aws_subnets.private_application_subnets.ids
    security_group_ids = data.aws_security_groups.vpc_default_sg.ids
    # assign_public_ip = true
  }
  type         = "MANAGED"
  state        = "ENABLED"
  service_role = aws_iam_role.aws_batch_service_role.arn

  depends_on = [
    aws_iam_role.aws_batch_service_role,
    aws_iam_policy.batch_service_role_policy,
    aws_iam_role_policy_attachment.aws_batch_service_role_policy_attach
  ]
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
  name     = "${var.prefix}-jpss1"
  state    = "ENABLED"
  priority = 10
  compute_environment_order {
    order               = 1
    compute_environment = aws_batch_compute_environment.generate_jpss1_fargate.arn
  }
  scheduling_policy_arn = aws_batch_scheduling_policy.generate_jpss1.arn
}
