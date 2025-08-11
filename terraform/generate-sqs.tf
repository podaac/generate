# Download lists
resource "aws_sqs_queue" "aws_sqs_queue_dlc" {
  name                       = "${var.prefix}-download-lists"
  visibility_timeout_seconds = 1800
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
# Aqua
resource "aws_sqs_queue" "aws_sqs_queue_pending_jobs_aqua" {
  name                       = "${var.prefix}-pending-jobs-aqua.fifo"
  visibility_timeout_seconds = 5
  sqs_managed_sse_enabled    = true
  fifo_queue                 = true
}

resource "aws_sqs_queue_policy" "aws_sqs_queue_policy_pending_jobs_aqua" {
  queue_url = aws_sqs_queue.aws_sqs_queue_pending_jobs_aqua.id
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
        "Resource" : "${aws_sqs_queue.aws_sqs_queue_pending_jobs_aqua.arn}"
      }
    ]
  })
}

# Terra
resource "aws_sqs_queue" "aws_sqs_queue_pending_jobs_terra" {
  name                       = "${var.prefix}-pending-jobs-terra.fifo"
  visibility_timeout_seconds = 5
  sqs_managed_sse_enabled    = true
  fifo_queue                 = true
}

resource "aws_sqs_queue_policy" "aws_sqs_queue_policy_pending_jobs_terra" {
  queue_url = aws_sqs_queue.aws_sqs_queue_pending_jobs_terra.id
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
        "Resource" : "${aws_sqs_queue.aws_sqs_queue_pending_jobs_terra.arn}"
      }
    ]
  })
}

# Viirs
resource "aws_sqs_queue" "aws_sqs_queue_pending_jobs_viirs" {
  name                       = "${var.prefix}-pending-jobs-viirs.fifo"
  visibility_timeout_seconds = 5
  sqs_managed_sse_enabled    = true
  fifo_queue                 = true
}

resource "aws_sqs_queue_policy" "aws_sqs_queue_policy_pending_jobs_viirs" {
  queue_url = aws_sqs_queue.aws_sqs_queue_pending_jobs_viirs.id
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
        "Resource" : "${aws_sqs_queue.aws_sqs_queue_pending_jobs_viirs.arn}"
      }
    ]
  })
}

# JPSS1
resource "aws_sqs_queue" "aws_sqs_queue_pending_jobs_jpss1" {
  name                       = "${var.prefix}-pending-jobs-jpss1.fifo"
  visibility_timeout_seconds = 5
  sqs_managed_sse_enabled    = true
  fifo_queue                 = true
}

resource "aws_sqs_queue_policy" "aws_sqs_queue_policy_pending_jobs_jpss1" {
  queue_url = aws_sqs_queue.aws_sqs_queue_pending_jobs_jpss1.id
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
        "Resource" : "${aws_sqs_queue.aws_sqs_queue_pending_jobs_jpss1.arn}"
      }
    ]
  })
}
