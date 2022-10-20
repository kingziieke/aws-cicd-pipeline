resource "aws_s3_bucket" "jz-codepipeline-artifacts" {
  bucket = "jz-pipeline-artifacts"
}

resource "aws_s3_bucket_acl" "jz-codepipeline-artifacts-acl" {
  bucket = aws_s3_bucket.jz-codepipeline-artifacts.id
  acl    = "private"
}