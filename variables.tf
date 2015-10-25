variable "access_key" {}
variable "secret_key" {}

variable "dbuser" {}
variable "dbpass" {}

variable "region" {
  default = "us-west-2"
}

variable "instance_name" {
  default = {
    utility = "theseeker"
    database = "squeezebox"
    web = "magicbus"
  }
}

variable "amis" {
  default = {
    us-east-1 = "ami-61bbf104"
    us-west-2 = "ami-d440a6e7"
    platform = "CentOS7"
  }
}


