variable "access_key" {}
variable "secret_key" {}
variable "region" {
  default = "us-west-2"
}
variable "instance_name" {
  default = {
    utility = "theseeker"
    database = "squeezebox"
  }
}
variable "amis" {
  default = {
    us-east-1 = "ami-61bbf104"
    us-west-2 = "ami-d440a6e7"
    platform = "CentOS7"
  }
}
variable "db" {
  default = {
    platform = "MySQL5.6"
    user = "borris"
    pass = "SlipKn0t97!"
  }
}
