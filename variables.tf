variable "access_key" {}
variable "secret_key" {}
variable "region" {
  default = "us-west-2"
}
variable "instance_name" {
  default = "theseeker"
}
variable "instance_tier" {
  default = "utility"
}
variable "amis" {
  default = {
    us-east-1 = "ami-61bbf104"
    us-west-2 = "ami-d440a6e7"
  }
}
