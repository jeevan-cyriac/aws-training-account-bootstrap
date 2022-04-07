resource "aws_s3_bucket" "tf_statefiles" {
  bucket = "jeevan-personal-training-terraform-statefiles"
}

resource "aws_s3_bucket_acl" "tf_statefiles" {
  bucket = aws_s3_bucket.tf_statefiles.id
  acl    = "private"
}

resource "aws_s3_bucket_versioning" "tf_statefiles" {
  bucket = aws_s3_bucket.tf_statefiles.id
  versioning_configuration {
    status = "Enabled"
  }
}
