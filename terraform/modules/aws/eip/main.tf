provider "aws" {
    region = "ap-southeast-1"
}

resource "aws_eip" "lb" {
    domain = "vpc"
}