variable "aws_region" {
  type = string
  description = "AWS region"
}

variable "aws_profile" {
  type = string
  description = "AWS user profile"
}

variable "name" {
  type = string
  description = "General name"
}

variable "environment" {
  type = string
  description = "Environment name"
}

variable "container_port" {
  type = number
  description = "Container Port"
}

variable "container_image" {
  type = string
  description = "Container Image"
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
