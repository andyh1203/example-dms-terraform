variable "db_subnet_group_name" {
  description = "Private DB Subnet group name"
  type        = string
}
variable "vpc_rds_security_group_ids" {
  description = "RDS VPC security group IDs"
  type        = list
  default     = []
}
variable "db_name" {
  description = "RDS schema / DB"
  type        = string
}
variable "db_instance_class" {
  description = "EC2 instance class"
  type        = string
  default     = "db.t2.micro"
}
variable "db_username" {
  description = "RDS Username"
  type        = string
}
variable "db_password" {
  description = "RDS Password"
  type        = string
}
variable "db_allocated_storage" {
  description = "Allocated storage to EBS volume"
  type        = number
  default     = 10
}
variable "db_storage_type" {
  description = "EBS volume storage type"
  type        = string
  default     = "gp2"
}
variable "db_engine" {
  description = "DB engine type"
  type        = string
  default     = "mysql"
}
variable "db_engine_version" {
  description = "DB engine version"
  type        = string
  default     = "5.7"
}
variable "db_skip_final_snapshot" {
  description = "Whether or not to skip final snapshot when destroying DB"
  type        = bool
  default     = true
}
