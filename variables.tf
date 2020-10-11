variable "aws_region" {
  type = string
  description = "AWS region"
}

variable "aws_profile" {
  default = "alessander"
}

variable "name" {
  default = "fargate"
}

variable "environment" {
  default = "test"
}

variable "container_port" {
  default = "80"
}

variable "container_image" {
  default = "nginx"
}

# variable "app_name" {
#   type = string
#   description = "Application name"
# }
# variable "app_environment" {
#   type = string
#   description = "Application environment"
# }
# variable "admin_sources_cidr" {
#   type = list(string)
#   description = "List of IPv4 CIDR blocks from which to allow admin access"
# }
# variable "app_sources_cidr" {
#   type = list(string)
#   description = "List of IPv4 CIDR blocks from which to allow application access"
# }
