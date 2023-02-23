# CloudWatch Logs

# Downloader
resource "aws_cloudwatch_log_group" "generate_cw_log_group_downloader" {
  name              = "/aws/batch/job/${var.prefix}-downloader/"
  retention_in_days = 120
}

resource "aws_cloudwatch_log_group" "generate_cw_log_group_downloader_error" {
  name              = "/aws/batch/job/${var.prefix}-downloader-errors/"
  retention_in_days = 120
}