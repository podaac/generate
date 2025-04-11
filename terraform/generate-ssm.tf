# SSM Parameter Store parameters for IDL licenses
# MODIS Aqua
resource "aws_ssm_parameter" "aws_ssm_parameter_ps_idl_aqua" {
  name  = "${var.prefix}-idl-aqua"
  type  = "String"
  value = "13"
}

# MODIS Terra
resource "aws_ssm_parameter" "aws_ssm_parameter_ps_idl_terra" {
  name  = "${var.prefix}-idl-terra"
  type  = "String"
  value = "13"
}

# VIIRS
resource "aws_ssm_parameter" "aws_ssm_parameter_ps_idl_viirs" {
  name  = "${var.prefix}-idl-viirs"
  type  = "String"
  value = "13"
}

# JPSS1
resource "aws_ssm_parameter" "aws_ssm_parameter_ps_idl_jpss1" {
  name  = "${var.prefix}-idl-jpss1"
  type  = "String"
  value = "13"
}

# Floating
resource "aws_ssm_parameter" "aws_ssm_parameter_ps_idl_floating" {
  name  = "${var.prefix}-idl-floating"
  type  = "String"
  value = "2"
}

# Retrieval indicator
resource "aws_ssm_parameter" "aws_ssm_parameter_ps_idl_ret" {
  name  = "${var.prefix}-idl-retrieving-license"
  type  = "String"
  value = "False"
}
