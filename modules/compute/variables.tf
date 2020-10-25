variable "public_key_path" {
  description = "Public key path"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}

variable "key_name" {
  description = "Name of the key to create"
  type        = string
  default     = "auth_key"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "ami" {
  description = "Amazon machine image to use for the instance"
  type        = string
  default     = "ami-01fee56b22f308154"
}

variable "instance_tags" {
  description = "Tags for the EC2 instance"
  type        = map(string)
  default = {
    Name = "My instance"
  }
}

variable "subnet_id" {
  description = "Identifier of the subnet to launch the instance in"
  type        = string
}

variable "vpc_security_group_ids" {
  description = "Security group IDs to attach to instance"
  type        = list(string)
}
