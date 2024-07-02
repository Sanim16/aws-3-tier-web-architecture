resource "aws_s3_bucket" "s3_bucket" {
  bucket        = "unique-bucket-name-aws-3-tier-msctf"
  force_destroy = true

  tags = {
    Name        = "3 tier web Code bucket"
    Environment = "Dev"
  }
}
