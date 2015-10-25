resource "aws_instance" "web" {
  key_name = "kpedersen_aws_rsa"
  ami = "${lookup(var.amis, var.region)}"
  instance_type = "t2.micro"
  root_block_device {
    delete_on_termination = true
  }
  availability_zone = "${element(split(",", lookup(var.azones, var.region)), 0)}"
  iam_instance_profile = "S3ReadOnlyAccess"
  vpc_security_group_ids = ["${aws_security_group.sg_web_access.id}"]

  tags {
    Name = "${lookup(var.instance_name, "web")}"
    Platform = "${var.amis.platform}"
    Tier = "web"
  }

  user_data = "${file("web.webtier.user-data.sh")}"
}

output "web_instance_id" {
  value = "${aws_instance.web.id}"
}
output "web_public_dns" {
  value = "${aws_instance.web.public_dns}"
}

resource "aws_instance" "www" {
  key_name = "kpedersen_aws_rsa"
  ami = "${lookup(var.amis, var.region)}"
  instance_type = "t2.micro"
  root_block_device {
    delete_on_termination = true
  }
  availability_zone = "${element(split(",", lookup(var.azones, var.region)), 1)}"
  iam_instance_profile = "S3ReadOnlyAccess"
  vpc_security_group_ids = ["${aws_security_group.sg_web_access.id}"]

  tags {
    Name = "${lookup(var.instance_name, "www")}"
    Platform = "${var.amis.platform}"
    Tier = "web"
  }

  user_data = "${file("www.webtier.user-data.sh")}"
}

output "www_instance_id" {
  value = "${aws_instance.www.id}"
}
output "www_public_dns" {
  value = "${aws_instance.www.public_dns}"
}

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

output "sg_web_access_id" {
  value = "${aws_security_group.sg_web_access.id}"
}

resource "aws_elb" "elb_external" {
  name = "external"
  availability_zones = ["${split(",", lookup(var.azones, var.region))}"]
  security_groups = ["${aws_security_group.sg_elb_access.id}"]

  listener {
    instance_port = 80
    instance_protocol = "http"
    lb_port = 80
    lb_protocol = "http"
  }

  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 30
    target = "HTTP:80/healthcheck.html"
    interval = 120
  }

  cross_zone_load_balancing = true
  idle_timeout = 600
  connection_draining = true
  connection_draining_timeout = 300

  instances = ["${aws_instance.web.id}", "${aws_instance.www.id}"]
}

resource "aws_security_group" "sg_elb_access" {
  name = "sg_elb_access"
  description = "Allow inbound http to the web tier"
  
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

output "sg_elb_access_id" {
  value = "${aws_security_group.sg_elb_access.id}"
}

resource "aws_route53_record" "www" {
  zone_id = "Z2OCSN1ZPHG5PO"
  name = "www.bytecount.net"
  type = "A"

  alias {
    name = "${aws_elb.elb_external.dns_name}"
    zone_id = "${aws_elb.elb_external.zone_id}"
    evaluate_target_health = false
  }
}
