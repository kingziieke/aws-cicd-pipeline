resource "aws_codebuild_project" "jz-tf-plan" {
  name         = "jz-tf-plan"
  description  = "Plan stage for terraform"
  service_role = aws_iam_role.jz-tf-codebuild-role.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/amazonlinux2-x86_64-standard:2.0"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = false
    type                        = "LINUX_CONTAINER"
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = file("buildspec/jz-plan-buildspec.yml")
  }
}

resource "aws_codebuild_project" "jz-tf-apply" {
  name         = "jz-tf-apply"
  description  = "Apply stage for terraform"
  service_role = aws_iam_role.jz-tf-codebuild-role.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/amazonlinux2-x86_64-standard:2.0"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = false
    type                        = "LINUX_CONTAINER"
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = file("buildspec/jz-apply-buildspec.yml")
  }
}

resource "aws_codepipeline" "jz-cicd_pipeline" {

  name     = "jz-tf-cicd"
  role_arn = aws_iam_role.jz-tf-codepipeline-role.arn

  artifact_store {
    type     = "S3"
    location = aws_s3_bucket.jz-codepipeline-artifacts.id
  }

  stage {
    name = "Source"
    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["tf-code"]
      configuration = {
        FullRepositoryId     = "kingziieke/aws-cicd-pipeline"
        BranchName           = "master"
        ConnectionArn        = var.codestar_connector_credentials
        OutputArtifactFormat = "CODE_ZIP"
      }
    }
  }

  stage {
    name = "Plan"
    action {
      name            = "Build"
      category        = "Build"
      provider        = "CodeBuild"
      version         = "1"
      owner           = "AWS"
      input_artifacts = ["tf-code"]
      configuration = {
        ProjectName = "jz-tf-plan"
      }
    }
  }

  stage {
    name = "Deploy"
    action {
      name            = "Deploy"
      category        = "Build"
      provider        = "CodeBuild"
      version         = "1"
      owner           = "AWS"
      input_artifacts = ["tf-code"]
      configuration = {
        ProjectName = "jz-tf-apply"
      }
    }
  }
}