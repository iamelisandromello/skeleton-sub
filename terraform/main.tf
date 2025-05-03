provider "aws" {
  region = var.region
}

# Bucket S3 para guardar o código zipado da função Lambda.
resource "aws_s3_bucket" "lambda_code_bucket" {
  bucket = "meu-unico-bucket-s3"
}

# IAM Role para a execução das funções Lambda.
resource "aws_iam_role" "lambda_execution_role" {
  name = "${var.project_name}_execution_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# Política de permissão da Role da Lambda para acessar SQS
resource "aws_iam_role_policy" "lambda_sqs_policy" {
  name = "lambda-sqs-policy"
  role = aws_iam_role.lambda_execution_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes"
        ],
        Resource = aws_sqs_queue.skeleton_pub_queue.arn
      }
    ]
  })
}

# Função Lambda
resource "aws_lambda_function" "my_lambda_function" {
  function_name = var.project_name
  role          = aws_iam_role.lambda_execution_role.arn
  handler       = "main/app.handler"
  runtime       = "nodejs20.x"
  s3_bucket     = aws_s3_bucket.lambda_code_bucket.bucket
  s3_key        = "${var.project_name}.zip"
  timeout       = 15

  environment {
    variables = var.lambda_env_vars
  }
}

# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name              = "/aws/lambda/${var.project_name}"
  retention_in_days = 14
}

# Fila SQS
resource "aws_sqs_queue" "skeleton_pub_queue" {
  name = "skeleton-pub-queue"
}

# Permissão para que a SQS invoque a Lambda
resource "aws_lambda_permission" "allow_sqs_invoke" {
  statement_id  = "AllowExecutionFromSQS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.my_lambda_function.function_name
  principal     = "sqs.amazonaws.com"
  source_arn    = aws_sqs_queue.skeleton_pub_queue.arn
}

# Mapeamento de evento da SQS para a Lambda
resource "aws_lambda_event_source_mapping" "from_sqs" {
  event_source_arn  = aws_sqs_queue.skeleton_pub_queue.arn
  function_name     = aws_lambda_function.my_lambda_function.arn
  batch_size        = 10
  enabled           = true
}
