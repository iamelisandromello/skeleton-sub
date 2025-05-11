provider "aws" {
  region = var.region
}

# Bucket S3 para guardar o código zipado da função Lambda.
# Sem instrução de criação, pois deve ser sempre importado e reutilizado conforme regras de negócio.
resource "aws_s3_bucket" "lambda_code_bucket" {
  bucket = "meu-unico-bucket-s3"
}

# IAM Role para a execução da função Lambda — assume role com permissão apenas para lambda.amazonaws.com
resource "aws_iam_role" "lambda_execution_role" {
  name = "${var.project_name}_execution_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# Inline policy para a Lambda poder escrever logs no CloudWatch
resource "aws_iam_role_policy" "lambda_logging_policy" {
  name = "${var.project_name}_logging_policy"
  role = aws_iam_role.lambda_execution_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "arn:aws:logs:${var.region}:*:log-group:/aws/lambda/${var.project_name}:*"
      }
    ]
  })
}

# CloudWatch Log Group para a função Lambda
resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name              = "/aws/lambda/${var.project_name}"
  retention_in_days = 14
}

# Função Lambda que deverá ser atualizada em caso de existência, nunca criar uma duplicata.
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

  depends_on = [aws_iam_role_policy.lambda_logging_policy]
}

# Recursos para QUEUES SQS
# Declaração da fila SQS (deve ser importada se já existir)
resource "aws_sqs_queue" "skeleton_pub_queue" {
  name = "${var.project_name}-queue"
}

# Permissão para que a SQS invoque a Lambda
resource "aws_lambda_permission" "allow_sqs_invoke" {
  statement_id  = "AllowExecutionFromSQS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.my_lambda_function.function_name
  principal     = "sqs.amazonaws.com"
  source_arn    = aws_sqs_queue.skeleton_pub_queue.arn
}

# Mapeamento da SQS como evento da Lambda
resource "aws_lambda_event_source_mapping" "from_sqs" {
  event_source_arn = aws_sqs_queue.skeleton_pub_queue.arn
  function_name    = aws_lambda_function.my_lambda_function.arn
  batch_size       = 10
  enabled          = true
}