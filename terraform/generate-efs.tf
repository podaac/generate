# Generate
# Volume
resource "aws_efs_file_system" "generate_efs_fs" {
  creation_token   = var.prefix
  encrypted        = true
  performance_mode = "generalPurpose"
  throughput_mode = "elastic"
  lifecycle_policy {
    transition_to_ia = "AFTER_1_DAY"
  } 
  tags             = { Name = "${var.prefix}" }
}

# Mount targets
resource "aws_efs_mount_target" "generate_efs_mt" {
  for_each        = data.aws_subnet.private_application_subnet
  file_system_id  = aws_efs_file_system.generate_efs_fs.id
  subnet_id       = each.value.id
  security_groups = concat(data.aws_security_groups.vpc_default_sg.ids, [aws_security_group.efs_sg.id])
}

# Access points
# Partition & Submit Lambda
resource "aws_efs_access_point" "generate_efs_ap_ps" {
  file_system_id = aws_efs_file_system.generate_efs_fs.id
  tags           = { Name = "${var.prefix}-partition-submit" }
  posix_user {
    gid = 0
    uid = 0
  }
  root_directory {
    creation_info {
      owner_gid   = 1000
      owner_uid   = 1000
      permissions = 0755
    }
    path = "/"
  }
}

# Error Checker Lambda
resource "aws_efs_access_point" "generate_efs_ap_ec" {
  file_system_id = aws_efs_file_system.generate_efs_fs.id
  tags           = { Name = "${var.prefix}-error-checker" }
  posix_user {
    gid = 0
    uid = 0
  }
  root_directory {
    creation_info {
      owner_gid   = 1000
      owner_uid   = 1000
      permissions = 0755
    }
    path = "/"
  }
}

# Reporter Lambda
resource "aws_efs_access_point" "generate_efs_ap_r" {
  file_system_id = aws_efs_file_system.generate_efs_fs.id
  tags           = { Name = "${var.prefix}-reporter" }
  posix_user {
    gid = 0
    uid = 0
  }
  root_directory {
    creation_info {
      owner_gid   = 1000
      owner_uid   = 1000
      permissions = 0755
    }
    path = "/processor"
  }
}

# CNM Responder Lambda
resource "aws_efs_access_point" "generate_efs_ap_cr" {
  file_system_id = aws_efs_file_system.generate_efs_fs.id
  tags           = { Name = "${var.prefix}-cnm-responder" }
  posix_user {
    gid = 0
    uid = 0
  }
  root_directory {
    creation_info {
      owner_gid   = 1000
      owner_uid   = 1000
      permissions = 0755
    }
    path = "/processor/output"
  }
}

# Purger Lambda
resource "aws_efs_access_point" "generate_efs_ap_p" {
  file_system_id = aws_efs_file_system.generate_efs_fs.id
  tags           = { Name = "${var.prefix}-purger" }
  posix_user {
    gid = 0
    uid = 0
  }
  root_directory {
    creation_info {
      owner_gid   = 1000
      owner_uid   = 1000
      permissions = 0755
    }
    path = "/"
  }
}