/* set up an external load balancer
   to manage distribution of connections */

resource "aws_elb" "external" {

  /* name of the ELB */
  name = "external"

  /* add the list of AZs for our web instances */
  availability_zones = ["${split(",", lookup(var.azones, var.region.backup))}"]

  /* add to the security group */
  security_groups = ["${aws_security_group.sg_elb_access.id}"]

  /* set up our listener */
  listener {
    instance_port = 80
    instance_protocol = "http"
    lb_port = 80
    lb_protocol = "http"
  }

  /* set up our health check */
  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 30
    target = "HTTP:80/healthcheck.html"
    interval = 120
  }

  /* configure for multi-AZ connection balancing */
  cross_zone_load_balancing = true

  /* set some general parameters */
  idle_timeout = 300
  connection_draining = true
  connection_draining_timeout = 300

  /* add our web instances to the load balancer */
  instances = ["${aws_instance.web.id}", "${aws_instance.www.id}"]
}

/* output the load balancer's connection information */
output "elb_connection_address" {
  value = "${aws_elb.external.dns_name}"
}

/* create the ELB security group */
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

/* output the group id */
output "sg_elb_access_id" {
  value = "${aws_security_group.sg_elb_access.id}"
}
