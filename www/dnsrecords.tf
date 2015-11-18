/* add the www record */
resource "aws_route53_record" "www" {
  zone_id = "${var.dnszone}"
  name = "www.bytecount.net"
  type = "A"

/* point the record at the ELB */
  alias {
    name = "${aws_elb.external.dns_name}"
    zone_id = "${aws_elb.external.zone_id}"
    evaluate_target_health = false
  }
}

