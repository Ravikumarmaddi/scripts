variable "access_key" {}
variable "secret_key" {}
variable "db_passwd" {}

/* Global variables */
variable "keypair" { default = "kpedersen_aws_rsa" }
variable "dnszone" { default = "Z2OCSN1ZPHG5PO" }

/* Local variables */
variable "keyfile" { default = "/home/kpedersen/.ssh/kpedersen_aws_rsa" }

/* Region-specific setup is below. Uses
   multiple regions, "primary" & "backup" for DR. */

variable "region" {
  default { 
    primary = "us-west-2"
    backup = "us-east-1"
  }
}

variable "ami" {
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

/* RDS instance */
variable "db" {
  default {
    dbid = "dbconnect"
    name = "dbconnect"
    user = "boris"
  }
}
