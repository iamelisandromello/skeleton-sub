locals {
  lambda_name        = var.project_name
  lambda_handler     = "index.handler"
  lambda_runtime     = "nodejs20.x"
  lambda_log_group   = "/aws/lambda/${var.project_name}"
  lambda_zip_key     = "${var.project_name}.zip"

  queue_name         = "${var.project_name}-queue"
  role_name          = "${var.project_name}_execution_role"
  policy_name        = "${var.project_name}_policy"
  bucket_name        = "meu-unico-bucket-s3" # pode parametrizar no futuro, se desejar
}
