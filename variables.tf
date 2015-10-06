variable "access_key" {}
variable "secret_key" {}
variable "region" {
  default = "us-west-2"
}
variable "amis" {
  default = {
    us-east-1 = "ami-588c7f30"
    us-west-2 = "ami-d34032e3"
  }
}
