/* set up a Hadoop cluster node */
resource "aws_instance" "cnode" {

  /* set the initial key for the instance */
  key_name = "${var.keypair}"

  /* select the appropriate AMI */
  ami = "${lookup(var.ami, var.region.primary)}"
  instance_type = "t2.micro"

  /* delete the volume on termination */
  root_block_device {
    delete_on_termination = true
  }

  /* provide S3 access to the system */
  iam_instance_profile = "S3FullAccess"

  /* add to the security group */
  vpc_security_group_ids = ["${aws_security_group.sg_cluster_access.id}"]

  tags {
    Name = "${lookup(var.cluster_nodes, count.index)}"
    Platform = "${var.ami.platform}"
    Tier = "cluster"
  }

  # cluster size
  count = "${var.count}"

  /* copy up and execute the user data script */
  provisioner "file" {
    source = "scripts/cnode_bootstrap.sh"
    destination = "/tmp/bootstrap.sh"
    connection {
      type = "ssh"
      user = "centos"
      key_file = "${var.keyfile}"
    }
  }
  provisioner "remote-exec" {
    inline = [
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
output "cnode_private_dns" {
  value = "${join(",", aws_instance.cnode.*.private_dns)}"
}

/* create the cluster tier security group */
resource "aws_security_group" "sg_cluster_access" {
  name = "sg_cluster_access"
  description = "Allow inbound ssh to the cluster tier"
  
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    security_groups = ["${aws_security_group.sg_utility_access.id}"]

  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

/* output the group id */
output "sg_cluster_access_id" {
  value = "${aws_security_group.sg_cluster_access.id}"
}