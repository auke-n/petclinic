terraform {
  backend "s3" {
    encrypt = true
    bucket  = "brso"
    region  = "eu-central-1"
    key     = "terraform.tfstate"
  }
}