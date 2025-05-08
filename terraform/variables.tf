# =========================
# Variáveis de ambiente do Projeto
# =========================

variable "TZ" {
  type = string
}

variable "CORS_ORIGIN_PERMISSION" {
  type = string
}

variable "EXAMPLE_QUEUE_URL" {
  type = string
}

variable "MESSAGE_TYPE_QUEUE {
  type = string
}

variable "MOCK_ACCESS_TOKEN" {
  type = string
}

# =========================
# Variáveis de ambiente da GitHub
# =========================

variable "project_name" {
  description = "Name of the project derived from GitHub Repository name"
  type        = string
}
  
# =========================
# Variáveis de ambiente da Lambda
# =========================

variable "region" {
  default = "us-east-1"
}

variable "lambda_env_vars" {
  description = "Mapa de variáveis de ambiente para a função Lambda"
  type        = map(string)
  default     = {}
}