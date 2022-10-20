terraform {
  backend "s3" {
    bucket  = "jz-aws-cicd-pipeline"
    encrypt = true
    key     = "terraform.tfstate"
    region  = "us-east-1"
  }
}

provider "aws" {
  region = "us-east-1"
}