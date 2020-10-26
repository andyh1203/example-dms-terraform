output "subnet_ids" {
  value = {
    "public_a" : aws_subnet.public_a.id
    "public_b" : aws_subnet.public_b.id
    "private_a" : aws_subnet.private_a.id
  }
}

output "vpc_security_group_ids" {
  value = [aws_security_group.my_instance_sg.id]
}

output "db_subnet_group_name" {
  value = aws_db_subnet_group.db_subnet_group.name
}

output "vpc_rds_security_group_id" {
  value = aws_security_group.db_sg.id
}

output "vpc_instance_security_group_id" {
  value = aws_security_group.my_instance_sg.id
}
