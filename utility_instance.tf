provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region = "${var.region}"
}

resource "aws_instance" "utility" {
  key_name = "kpedersen_aws_rsa"
  ami = "${lookup(var.amis, var.region)}"
  instance_type = "t2.micro"
  vpc_security_group_ids = ["${aws_security_group.sg_utility_access.id}"]

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

resource "aws_security_group" "sg_utility_access" {
  name = "sg_utility_access"
  description = "Allow inbound ssh to the utility tier"
  
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "group_id" {
  value = "${aws_security_group.sg_utility_access.id}"
}
