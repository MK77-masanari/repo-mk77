variable "aws_access_key" {}
variable "aws_secret_key" {}

provider "aws" {
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  region = "ap-northeast-3"
}

resource "aws_vpc" "mk-vpc" {
  cidr_block = "10.0.2.0/24"
  tags = {
    Name = "mk-vpc"
  }
}
