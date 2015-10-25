module "az" {
  source = "github.com/terraform-community-modules/tf_aws_availability_zones"
  region = "${var.region}"
  account = "kpedersen"
}
