terraform {
  #############################################################
  ## AFTER RUNNING TERRAFORM APPLY (WITH LOCAL BACKEND)
  ## YOU WILL UNCOMMENT THIS CODE THEN RERUN TERRAFORM INIT
  ## TO SWITCH FROM LOCAL BACKEND TO REMOTE AWS BACKEND
  #############################################################
  backend "s3" {
    bucket         = "tfstate-dev-2023" # REPLACE WITH YOUR BUCKET NAME
    key            = "backend/terraform-dev-env.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "remote-atomic-lock" # REPLACE WITH YOUR DYNAMODB TABLE NAME
    encrypt        = true
  }
}