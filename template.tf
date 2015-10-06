provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region = "${var.region}"
}

resource "aws_instance" "ubuntu" {
  ami = "ami-d34032e3"
  instance_type = "t2.micro"
}
