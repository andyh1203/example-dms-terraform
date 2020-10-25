resource "random_id" "wp_code_bucket" {
  byte_length = 6
}

resource "aws_s3_bucket" "code" {
  bucket        = "dms-target-${random_id.wp_code_bucket.dec}"
  acl           = "private"
  force_destroy = false
  tags = {
    Name = "DMS Target Bucket"
  }
}
