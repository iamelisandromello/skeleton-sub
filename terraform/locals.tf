locals {
  lambda_name      = var.project_name
  lambda_handler   = "index.handler"
  lambda_runtime   = "nodejs20.x"
  lambda_zip_key   = "${var.project_name}.zip"
  lambda_log_group = "/aws/lambda/${var.project_name}"

  queue_name = "${var.project_name}-queue"

  role_name   = "${var.project_name}_execution_role"
  policy_name = "${var.project_name}_policy"
}
