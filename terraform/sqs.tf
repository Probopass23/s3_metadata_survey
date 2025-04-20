data "aws_caller_identity" "current" {}

resource "aws_sqs_queue" "for_s3_put_lambda" {
  name                      = "queue-for-s3-put-lambda"
  message_retention_seconds = 3600
}

resource "aws_sqs_queue_policy" "for_s3_put_lambda" {
  queue_url = aws_sqs_queue.for_s3_put_lambda.id
  policy    = data.aws_iam_policy_document.for_s3_put_lambda.json
}

data "aws_iam_policy_document" "for_s3_put_lambda" {
  statement {
    sid    = "First"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = [data.aws_caller_identity.current.account_id]
    }

    actions = [
      "sqs:SendMessage",
      "sqs:GetQueueUrl",
    ]
    resources = [aws_sqs_queue.for_s3_put_lambda.arn]
  }
}
