resource "aws_security_group" "efs_sg" {
  name        = "${var.prefix}-efs-mount-target"
  description = "Allow NFS traffic to EFS mount targets"
  vpc_id      = data.aws_vpc.application_vpc.id
  tags        = local.default_tags
}

resource "aws_security_group_rule" "efs_sg_ingress" {
  type              = "ingress"
  from_port         = 2049
  to_port           = 2049
  protocol          = "tcp"
  cidr_blocks       = local.private_application_subnet_cidr_blocks
  security_group_id = aws_security_group.efs_sg.id
}

resource "aws_security_group_rule" "default_egress" {
  type              = "egress"
  to_port           = 0
  from_port         = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
  security_group_id = aws_security_group.efs_sg.id
}