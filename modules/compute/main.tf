# Key pair
resource "aws_key_pair" "auth" {
  key_name   = var.key_name
  public_key = file(var.public_key_path)
}

resource "aws_instance" "jump_host" {
  instance_type          = var.instance_type
  ami                    = var.ami
  tags                   = var.instance_tags
  key_name               = aws_key_pair.auth.key_name
  subnet_id              = var.subnet_id
  vpc_security_group_ids = var.vpc_security_group_ids
}
