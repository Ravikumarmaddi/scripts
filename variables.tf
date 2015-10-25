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
    www = "babaoriley"
  }
}

variable "amis" {
  default = {
    us-east-1 = "ami-61bbf104"
    us-west-2 = "ami-d440a6e7"
    platform = "CentOS7"
  }
}

variable "subnets" {
  default = {
    us-east-1 = "subnet-edc2bac5,subnet-b396a9c7"
    us-west-2 = "subnet-860419e4,subnet-c9615dbd"
  }
}

variable "azones" {
  default = {
    us-east-1 = "us-east-1b,us-east-1c"
    us-west-2 = "us-west-2a,us-west-2b"
  }
}
