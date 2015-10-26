/* Set up web hosts in the backup
   region (settings in variables.tf) */

resource "aws_instance" "web" {

  /* set the initial key for the instance */
  key_name = "${var.keypair}"

  /* select the appropriate ami */
  ami = "${lookup(var.ami, var.region.backup)}"
  instance_type = "t2.micro"

  /* delete the volume on termination */
  root_block_device {
    delete_on_termination = true
  }

  /* place in the first AZ, index 0 in our list */
  availability_zone = "${element(split(",", lookup(var.azones, var.region.backup)), 0)}"

  /* provide S3 access to the system */
  iam_instance_profile = "S3ReadOnlyAccess"

  /* add to the security group */
  vpc_security_group_ids = ["${aws_security_group.sg_web_access.id}"]

  /* tag the instance */
  tags {
    Name = "web"
    Platform = "${var.ami.platform}"
    Tier = "web"
  }

  /* pass some user data; could subtitute a provisioner 
  user_data = "${file("scripts/web_bootstrap.sh")}"
  */

  /* trying out a provisioner setup */

  /* copy up and execute the user data script */
  provisioner "file" {
    source = "scripts/web_bootstrap.sh"
    destination = "/tmp/bootstrap.sh"
    connection {
      type = "ssh"
      user = "centos"
      key_file = "${var.keyfile}"
    }
  }
  provisioner "remote-exec" {
    inline = [
    "sed -i s/DBCONN=\"\"/DBCONN=\"${aws_db_instance.database.endpoint}\"/ /tmp/bootstrap.sh",
    "chmod +x /tmp/bootstrap.sh",
    "sudo /tmp/bootstrap.sh"
    ]
    connection {
      type = "ssh"
      user = "centos"
      key_file = "${var.keyfile}"
    }
  }
}

/* output the instance address */
output "web_public_dns" {
  value = "${aws_instance.web.public_dns}"
}


resource "aws_instance" "www" {

  /* set the initial key for the instance */
  key_name = "${var.keypair}"

  /* select the appropriate ami */
  ami = "${lookup(var.ami, var.region.backup)}"
  instance_type = "t2.micro"

  /* delete the volume on termination */
  root_block_device {
    delete_on_termination = true
  }

  /* place in the second AZ, index 1 in our list */
  availability_zone = "${element(split(",", lookup(var.azones, var.region.backup)), 1)}"

  /* provide S3 access to the system */
  iam_instance_profile = "S3ReadOnlyAccess"

  /* add to the security group */
  vpc_security_group_ids = ["${aws_security_group.sg_web_access.id}"]

  /* tag the instance */
  tags {
    Name = "www"
    Platform = "${var.ami.platform}"
    Tier = "web"
  }

  /* pass some user data; could subtitute a provisioner
  user_data = "${file("scripts/www_bootstrap.sh")}"
  */

  /* trying out a provisioner setup */

  /* copy up and execute the user data script */
  provisioner "file" {
    source = "scripts/www_bootstrap.sh"
    destination = "/tmp/bootstrap.sh"
    connection {
      type = "ssh"
      user = "centos"
      key_file = "${var.keyfile}"
    }
  }
  provisioner "remote-exec" {
    inline = [
    "sed -i s/DBCONN=\"\"/DBCONN=\"${aws_db_instance.database.endpoint}\"/ /tmp/bootstrap.sh",
    "chmod +x /tmp/bootstrap.sh",
    "sudo /tmp/bootstrap.sh"
    ]
    connection {
      type = "ssh"
      user = "centos"
      key_file = "${var.keyfile}"
    }
  }

}

/* output the instance address */
output "www_public_dns" {
  value = "${aws_instance.www.public_dns}"
}

/* create the web tier security group */
resource "aws_security_group" "sg_web_access" {
  name = "sg_web_access"
  description = "Allow inbound ssh, http to the web tier"

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    from_port = 80
    to_port = 80
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
output "sg_web_access_id" {
  value = "${aws_security_group.sg_web_access.id}"
}
