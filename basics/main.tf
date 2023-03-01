terraform {
    backend "s3" {
      bucket = "terraform-up-and-running-state-tf-learning"
      key = "global/s3/terraform.tfstate"
      region = "us-east-1"

      dynamodb_table = "terraform-up-and-running-locks"
      encrypt = true
    }
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "~> 4.16"

    }
  }
}

provider "aws" {
    region = "us-east-1"
}

resource "aws_s3_bucket" "terraform_state" {
  name = "nishanth_devops_terraform_bucket-2023"

  lifecycle {
    prevent_destroy = true
  }

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

resource "aws_dynamodb_table" "terraform_locks" {
  name = "terraform-up-and-running-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key = "LockID"

  attribute {
    name = "LockID"
    type = S
  }
}