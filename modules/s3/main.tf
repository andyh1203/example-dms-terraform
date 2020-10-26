resource "random_id" "default" {
  byte_length = 6
}

resource "aws_s3_bucket" "dms_target" {
  bucket        = "dms-target-${random_id.default.dec}"
  acl           = "private"
  force_destroy = false
  tags = {
    Name = "DMS Target Bucket"
  }
}
