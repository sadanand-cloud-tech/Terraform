terraform {
  backend "s3" {
    bucket = "sadanan"
    key    = "day-4/terraform.tfstate"
    region = "us-east-1"
    use_lockfile = true # to use s3 native locking 1.19 version above
  }
}