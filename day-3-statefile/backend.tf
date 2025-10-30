terraform {
  backend "s3" {
    bucket = "sadanan"
    key    = "day-3/terraform.tfstate"
    region = "us-east-1"
  }
}