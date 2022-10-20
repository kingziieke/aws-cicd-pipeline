resource "aws_s3_bucket" "jz-codepipeline-artifacts" {
  bucket = "jz-pipeline-artifacts"
  acl    = "private"
}