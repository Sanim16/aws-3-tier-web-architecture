variable "vpc_cidr" {
  type        = string
  description = "cidr block for the vpc"
  default     = "10.0.0.0/16"
}

variable "db_password" {
  description = "RDS root user password"
  sensitive   = true
}
