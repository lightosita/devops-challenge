terraform {
  backend "s3" {
    bucket         = "devops-challenge-tfstate-858431073224"
    key            = "dev/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-state-lock"
  }
}