variable "db_username" {
  description = "RDS Username"
  type        = string
}

variable "db_password" {
  description = "RDS Password"
  type        = string
}

variable "db_hostname" {
  description = "Hostname of the RDS instance"
  type        = string
}

variable "public_a_subnet_id" {
  description = "ID of the public_a subnet"
  type        = string
}

variable "public_b_subnet_id" {
  description = "ID of the public_b subnet"
  type        = string
}

variable "vpc_rds_security_group_id" {
  description = "ID of the RDS SG"
  type        = string
}

variable "vpc_instance_security_group_id" {
  description = "ID of the SG providing SSH access"
  type        = string
}

variable "dms_target_bucket_name" {
  description = "DMS Target S3 bucket name"
  type        = string
}

variable "dms_vpc_management_role" {
  description = "DMS VPC Management role"
}

variable "dms_s3_access_role_arn" {
  description = "DMS S3 access role ARN"
}
