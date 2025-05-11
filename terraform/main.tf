provider "aws" {
  region = var.aws_region
}

# S3 bucket para código da Lambda
resource "aws_s3_bucket" "lambda_code_bucket" {
  bucket = "meu-unico-bucket-s3"
  force_destroy = true
}

# Função Lambda
resource "aws_lambda_function" "my_lambda_function" {
  function_name = var.project_name
  s3_bucket     = aws_s3_bucket.lambda_code_bucket.id
  s3_key        = "${var.project_name}.zip"
  handler       = "index.handler"
  runtime       = "nodejs20.x"
  role          = aws_iam_role.lambda_execution_role.arn
  timeout       = 30

  environment {
    variables = var.lambda_env_vars
  }
}

# Grupo de logs do CloudWatch
resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name              = "/aws/lambda/${aws_lambda_function.my_lambda_function.function_name}"
  retention_in_days = 14
}

# Fila SQS
resource "aws_sqs_queue" "skeleton_pub_queue" {
  name = "${var.project_name}-queue"
}

# Role de execução da Lambda
resource "aws_iam_role" "lambda_execution_role" {
  name = "${var.project_name}_execution_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action    = "sts:AssumeRole",
      Effect    = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

# Permissões básicas + acesso à SQS
resource "aws_iam_role_policy" "allow_lambda_logging_and_sqs" {
  name = "lambda-logging-and-sqs"
  role = aws_iam_role.lambda_execution_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "*"
      },
      {
        Effect   = "Allow",
        Action   = [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes"
        ],
        Resource = aws_sqs_queue.skeleton_pub_queue.arn
      }
    ]
  })
}

# Permissão para SQS invocar a Lambda
resource "aws_lambda_permission" "allow_sqs_invoke" {
  statement_id  = "AllowExecutionFromSQS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.my_lambda_function.function_name
  principal     = "sqs.amazonaws.com"
  source_arn    = aws_sqs_queue.skeleton_pub_queue.arn
}

# Mapeamento entre a SQS e a Lambda
resource "aws_lambda_event_source_mapping" "from_sqs" {
  event_source_arn = aws_sqs_queue.skeleton_pub_queue.arn
  function_name    = aws_lambda_function.my_lambda_function.arn
  batch_size       = 5
  enabled          = true
}
