/* set up a utility host for general
   admin and access to the environment */

resource "aws_instance" "utility" {

  /* set the initial key for the instance */
  key_name = "${var.keypair}"

  /* select the appropriate AMI */
  ami = "${lookup(var.ami, var.region.primary)}"
  instance_type = "t2.micro"

  /* provide S3 access to the system */
  iam_instance_profile = "S3FullAccess"

  /* add to the security group */
  vpc_security_group_ids = ["${aws_security_group.sg_utility_access.id}"]

  tags {
    Name = "util"
    Platform = "${var.ami.platform}"
    Tier = "utility"
  }

  user_data = "${file("scripts/util_bootstrap.sh")}"
}

/* output the instance address */
output "util_public_dns" {
  value = "${aws_instance.utility.public_dns}"
}

/* create the utility tier security group */
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

/* output the group id */
output "sg_utility_access_id" {
  value = "${aws_security_group.sg_utility_access.id}"
}
