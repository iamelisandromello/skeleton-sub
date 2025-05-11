locals {
  project_name      = var.project_name
  lambda_name       = "${local.project_name}-lambda"
  queue_name        = "${local.project_name}-queue"
  role_name         = "${local.project_name}-execution-role"
  policy_name       = "${local.project_name}-lambda-policy"
  bucket_name       = "${local.project_name}-lambda-bucket"
  lambda_zip_key    = "${local.project_name}.zip"
  lambda_handler    = "index.handler"
  lambda_runtime    = "nodejs20.x"
  lambda_log_group  = "/aws/lambda/${local.lambda_name}"
}
