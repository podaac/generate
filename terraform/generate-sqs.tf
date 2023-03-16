# Download lists
resource "aws_sqs_queue" "aws_sqs_queue_dlc" {
  name                       = "${var.prefix}-download-lists"
  visibility_timeout_seconds = 300
  sqs_managed_sse_enabled    = true
}

resource "aws_sqs_queue_policy" "aws_sqs_queue_policy_dlc" {
  queue_url = aws_sqs_queue.aws_sqs_queue_dlc.id
  policy = jsonencode({
    "Version" : "2008-10-17",
    "Id" : "__default_policy_ID",
    "Statement" : [
      {
        "Sid" : "__owner_statement",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : "${local.account_id}"
        },
        "Action" : [
          "SQS:*"
        ],
        "Resource" : "${aws_sqs_queue.aws_sqs_queue_dlc.arn}"
      }
    ]
  })
}

# Pending jobs
resource "aws_sqs_queue" "aws_sqs_queue_pending_jobs" {
  name                       = "${var.prefix}-pending-jobs"
  visibility_timeout_seconds = 300
  sqs_managed_sse_enabled    = true
}

resource "aws_sqs_queue_policy" "aws_sqs_queue_policy_pending_jobs" {
  queue_url = aws_sqs_queue.aws_sqs_queue_pending_jobs.id
  policy = jsonencode({
    "Version" : "2008-10-17",
    "Id" : "__default_policy_ID",
    "Statement" : [
      {
        "Sid" : "__owner_statement",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : "${local.account_id}"
        },
        "Action" : [
          "SQS:*"
        ],
        "Resource" : "${aws_sqs_queue.aws_sqs_queue_pending_jobs.arn}"
      }
    ]
  })
}