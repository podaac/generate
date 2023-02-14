# SNS topic for CNM responses
resource "aws_sns_topic" "aws_sns_topic_cnm_response" {
  name         = "${var.prefix}-cnm-response"
  display_name = "${var.prefix}-cnm-response"
}

resource "aws_sns_topic_policy" "aws_sns_topic_cnm_response_policy" {
  arn = aws_sns_topic.aws_sns_topic_cnm_response.arn
  policy = jsonencode({
    "Version" : "2008-10-17",
    "Id" : "__default_policy_ID",
    "Statement" : [
      {
        "Sid" : "__default_statement_ID",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : "*"
        },
        "Action" : [
          "SNS:GetTopicAttributes",
          "SNS:SetTopicAttributes",
          "SNS:AddPermission",
          "SNS:RemovePermission",
          "SNS:DeleteTopic",
          "SNS:Subscribe",
          "SNS:ListSubscriptionsByTopic",
          "SNS:Publish"
        ],
        "Resource" : "${aws_sns_topic.aws_sns_topic_cnm_response.arn}",
        "Condition" : {
          "StringEquals" : {
            "AWS:SourceOwner" : "${local.account_id}"
          }
        }
      }
    ]
  })
}