# Downloader
# Volume
resource "aws_efs_file_system" "generate_efs_fs_downloader" {
  creation_token   = "${var.prefix}-downloader"
  encrypted        = true
  performance_mode = "generalPurpose"
  tags             = merge(local.default_tags, { Name = "${var.prefix}-downloader" })
}

# Mount targets
resource "aws_efs_mount_target" "generate_efs_mt_downloader" {
  for_each        = data.aws_subnet.private_application_subnet
  file_system_id  = aws_efs_file_system.generate_efs_fs_downloader.id
  subnet_id       = each.value.id
  security_groups = concat(data.aws_security_groups.vpc_default_sg.ids, [aws_security_group.efs_sg.id])
}

# Combiner
# Volume
resource "aws_efs_file_system" "generate_efs_fs_combiner" {
  creation_token   = "${var.prefix}-combiner"
  encrypted        = true
  performance_mode = "generalPurpose"
  tags             = merge(local.default_tags, { Name = "${var.prefix}-combiner" })
}

# Mount targets
resource "aws_efs_mount_target" "generate_efs_mt_combiner" {
  for_each        = data.aws_subnet.private_application_subnet
  file_system_id  = aws_efs_file_system.generate_efs_fs_combiner.id
  subnet_id       = each.value.id
  security_groups = concat(data.aws_security_groups.vpc_default_sg.ids, [aws_security_group.efs_sg.id])
}

# Processor
# Volume
resource "aws_efs_file_system" "generate_efs_fs_processor" {
  creation_token   = "${var.prefix}-processor"
  encrypted        = true
  performance_mode = "generalPurpose"
  tags             = merge(local.default_tags, { Name = "${var.prefix}-processor" })
}

# Mount targets
resource "aws_efs_mount_target" "generate_efs_mt_processor" {
  for_each        = data.aws_subnet.private_application_subnet
  file_system_id  = aws_efs_file_system.generate_efs_fs_processor.id
  subnet_id       = each.value.id
  security_groups = concat(data.aws_security_groups.vpc_default_sg.ids, [aws_security_group.efs_sg.id])
}