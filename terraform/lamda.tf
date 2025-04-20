data "archive_file" "put_s3_lambda" {
  type        = "zip"
  source_dir  = "lambda/put_s3"
  output_path = "lambda/put_s3/lambda.zip"
}

resource "aws_lambda_function" "put_s3_lambda" {
  function_name    = "put-s3-orders"
  filename         = data.archive_file.put_s3_lambda.output_path
  source_code_hash = data.archive_file.put_s3_lambda.output_base64sha256
  runtime          = "python3.12"
  role             = aws_iam_role.put_s3_lambda.arn
  handler          = "put_s3.handler"

  environment {
    variables = {
      USE_METADATA = "True"
      S3_BUCKET    = "xxxxxxx"
    }
  }
}

resource "aws_iam_role" "put_s3_lambda" {
  name               = "put_s3_lambda"
  assume_role_policy = data.aws_iam_policy_document.put_s3_lambda.json
}

data "aws_iam_policy_document" "put_s3_lambda" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_policy" "put_s3_lambda" {
  name = "put-s3-lambda-policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes",
          "sqs:ReceiveMessage",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action = [
          "s3:PutObject",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "put_s3_lambda" {
  role       = aws_iam_role.put_s3_lambda.name
  policy_arn = aws_iam_policy.put_s3_lambda.arn
}

# SQS
resource "aws_lambda_event_source_mapping" "put_s3_lambda" {
  batch_size                         = 50
  maximum_batching_window_in_seconds = 20
  event_source_arn                   = aws_sqs_queue.for_s3_put_lambda.arn
  function_name                      = aws_lambda_function.put_s3_lambda.arn
}

# CloudWatch Logs
resource "aws_cloudwatch_log_group" "example" {
  name              = "/aws/lambda/${aws_lambda_function.put_s3_lambda.function_name}"
  retention_in_days = 14
}
