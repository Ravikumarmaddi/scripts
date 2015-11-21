variable "access_key" {}
variable "secret_key" {}

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
    us-east-1 = "ami-57cd8732"
    us-west-2 = "ami-1255b321"
    platform = "CentOS6"
  }
}

variable "azones" {
  default = {
    us-east-1 = "us-east-1b,us-east-1c"
    us-west-2 = "us-west-2a,us-west-2b"
  }
}

variable "count" {
  default = {
    "cnodes" = 4
    "mnodes" = 2
  }
}

variable "cluster_nodes" {
  default = {
    "0" = "cnode0"
    "1" = "cnode1"
    "2" = "cnode2"
    "3" = "cnode3"
    "4" = "cnode4"
    "5" = "cnode5"
  }
}

variable "master_nodes" {
  default = {
    "0" = "mnode0"
    "1" = "mnode1"
  }
}
