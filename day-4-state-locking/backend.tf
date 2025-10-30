terraform {
  backend "s3" {
    bucket = "sadanan"
    key    = "day-4/terraform.tfstate"
    region = "us-east-1"
  }
}