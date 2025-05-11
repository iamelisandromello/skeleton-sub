# ====================
# ✅ Provider AWS
# ====================
provider "aws" {
  region = var.region
}

# ================================
# 📦 Bucket S3 (referência existente)
# ================================
data "aws_s3_bucket" "lambda_code_bucket" {
  bucket = local.bucket_name
}

# ====================
# 🧠 Função Lambda
# ====================
resource "aws_lambda_function" "my_lambda_function" {
  function_name = local.lambda_name
  s3_bucket     = data.aws_s3_bucket.lambda_code_bucket.bucket
  s3_key        = local.lambda_zip_key
  handler       = local.lambda_handler
  runtime       = local.lambda_runtime
  role          = aws_iam_role.lambda_execution_role.arn
  timeout       = 30

  environment {
    variables = var.lambda_env_vars
  }
}

# ================================
# 📂 Grupo de logs do CloudWatch
# ================================
resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name              = local.lambda_log_group
  retention_in_days = 14
}

# ====================
# 📩 Fila SQS
# ====================
resource "aws_sqs_queue" "pub_queue" {
  name = local.queue_name
}

# ================================
# 🔐 Role de execução da Lambda
# ================================
resource "aws_iam_role" "lambda_execution_role" {
  name = local.role_name

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

# ========================================================
# 🔓 Permissões básicas para CloudWatch + acesso à SQS
# ========================================================
resource "aws_iam_role_policy" "allow_lambda_logging_and_sqs" {
  name = local.policy_name
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
        Resource = aws_sqs_queue.pub_queue.arn
      }
    ]
  })
}

# ==================================================
# 📛 Permissão para SQS invocar a função Lambda
# ==================================================
resource "aws_lambda_permission" "allow_sqs_invoke" {
  statement_id  = "AllowExecutionFromSQS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.my_lambda_function.function_name
  principal     = "sqs.amazonaws.com"
  source_arn    = aws_sqs_queue.pub_queue.arn

  # 🔒 Evita race condition entre criação da fila e lambda
  depends_on = [
    aws_lambda_function.my_lambda_function,
    aws_sqs_queue.pub_queue
  ]
}

# ============================================================
# 🔁 Mapeamento de eventos: conecta a fila SQS à função Lambda
# ============================================================
resource "aws_lambda_event_source_mapping" "from_sqs" {
  event_source_arn = aws_sqs_queue.pub_queue.arn
  function_name    = aws_lambda_function.my_lambda_function.arn
  batch_size       = 5
  enabled          = true
}
