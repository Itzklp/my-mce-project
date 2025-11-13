variable "aws_region" { default = "us-east-1" }
variable "project_suffix" { default = "mce" }

variable "vpc_cidr" { default = "10.10.0.0/16" }
variable "public_subnets" { default = ["10.10.1.0/24","10.10.2.0/24","10.10.3.0/24"] }
variable "private_subnets" { default = ["10.10.11.0/24","10.10.12.0/24","10.10.13.0/24"] }

# RDS variables
variable "db_username" { default = "mce_admin" }
variable "db_password" { default = "ChangeMe123!" } # replace before production
