# CloudWatch Alarm
resource "aws_cloudwatch_metric_alarm" "aws_cloudwatch_ec2_vcpu_alarm" {
  alarm_name          = "${var.prefix}-ec2-vcpu-alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  threshold           = "85"
  alarm_description   = "Alarm for when EC2 vCPU usage passes the 85% threshold for all available vCPUs in the account."
  alarm_actions       = [aws_sns_topic.aws_sns_topic_cloudwatch_alarms.arn]
  metric_query {
    id          = "e1"
    expression  = "m1/SERVICE_QUOTA(m1)*100"
    label       = "Percentage"
    return_data = "true"
  }
  metric_query {
    id = "m1"
    metric {
      metric_name = "ResourceCount"
      namespace   = "AWS/Usage"
      period      = "180"
      stat        = "Average"
      dimensions = {
        Type     = "Resource"
        Service  = "EC2"
        Resource = "vCPU"
        Class    = "Standard/OnDemand"
      }
    }
  }
}

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