# Generate
# Volume
resource "aws_efs_file_system" "generate_efs_fs" {
  creation_token   = var.prefix
  encrypted        = true
  performance_mode = "generalPurpose"
  tags             = { Name = "${var.prefix}" }
}

# Mount targets
resource "aws_efs_mount_target" "generate_efs_mt" {
  for_each        = data.aws_subnet.private_application_subnet
  file_system_id  = aws_efs_file_system.generate_efs_fs.id
  subnet_id       = each.value.id
  security_groups = concat(data.aws_security_groups.vpc_default_sg.ids, [aws_security_group.efs_sg.id])
}

# Access point
resource "aws_efs_access_point" "generate_efs_ap" {
  file_system_id = aws_efs_file_system.generate_efs_fs.id
  tags           = { Name = "${var.prefix}-access-point" }
}