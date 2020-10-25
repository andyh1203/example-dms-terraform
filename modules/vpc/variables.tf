variable "vpc_cidr_block" {
  description = "VPC CIDR block"
  type        = string
  default     = "10.0.0.0/16"

}

variable "enable_dns_hostnames" {
  description = "Should be true to enable DNS hostnames in the VPC"
  type        = bool
  default     = true
}

variable "enable_dns_support" {
  description = "Should be true to enable DNS support in the VPC"
  type        = bool
  default     = true
}

variable "vpc_tags" {
  description = "Additional tags for the VPC"
  type        = map(string)
  default     = {}
}

variable "igw_tags" {
  description = "Additional tags for the internet gateway"
  type        = map(string)
  default     = {}
}

variable "subnet_cidrs" {
  description = "Map of subnet CIDRs"
  type        = map(string)
  default = {
    "public_a" : "10.0.1.0/24"
    "private_a" : "10.0.2.0/24",
    "private_b" : "10.0.3.0/24"
  }
}

variable "local_ip" {
  description = "Your local IP address"
  type        = string
}
