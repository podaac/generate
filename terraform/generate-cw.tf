# CloudWatch Logs

# Downloader
resource "aws_cloudwatch_log_group" "generate_cw_log_group_downloader" {
  name              = "/aws/batch/job/${var.prefix}-downloader/"
  retention_in_days = 0
}

resource "aws_cloudwatch_log_group" "generate_cw_log_group_downloader_error" {
  name              = "/aws/batch/job/${var.prefix}-downloader-errors/"
  retention_in_days = 0
}

# Combiner
resource "aws_cloudwatch_log_group" "generate_cw_log_group_combiner" {
  name              = "/aws/batch/job/${var.prefix}-combiner/"
  retention_in_days = 0
}

resource "aws_cloudwatch_log_group" "generate_cw_log_group_combiner_error" {
  name              = "/aws/batch/job/${var.prefix}-combiner-errors/"
  retention_in_days = 0
}

# Processor
resource "aws_cloudwatch_log_group" "generate_cw_log_group_processor" {
  name              = "/aws/batch/job/${var.prefix}-processor/"
  retention_in_days = 0
}

resource "aws_cloudwatch_log_group" "generate_cw_log_group_processor_error" {
  name              = "/aws/batch/job/${var.prefix}-processor-errors/"
  retention_in_days = 0
}

# Uploader
resource "aws_cloudwatch_log_group" "generate_cw_log_group_uploader" {
  name              = "/aws/batch/job/${var.prefix}-uploader/"
  retention_in_days = 0
}

# CloudWatch Logs
resource "aws_cloudwatch_log_group" "generate_cw_log_group_license_returner" {
  name              = "/aws/batch/job/${var.prefix}-license-returner/"
  retention_in_days = 0
}