provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region = "${var.region}"
}

resource "aws_instance" "utility" {
  key_name = "kpedersen_aws_rsa"
  ami = "${lookup(var.amis, var.region)}"
  instance_type = "t2.micro"
  tags {
    Name = "${var.instance_name}"
    Platform = "${var.amis.platform}"
    Tier = "${var.instance_tier}"
  }
  user_data = "template.utility.user-data.sh"
}

output "instance_id" {
  value = "${aws_instance.utility.id}"
}
output "public_dns" {
  value = "${aws_instance.utility.public_dns}"
}
