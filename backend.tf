terraform {
  backend "s3" {
    bucket = "terraformpandotesting"
    key    = "terraformtest.tfstate"
    region = "ap-south-1"
    # dynamodb_table = "terraform-locking-pando"
    # encrypt        = true
  }
}