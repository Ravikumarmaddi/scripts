/* set up the database */

resource "aws_db_instance" "database" {

  /* connect identifier */
  identifier = "${var.db.dbid}"

  /* storage allocation */
  allocated_storage = 5

  /* engine configuration */
  engine = "mysql"
  engine_version = "5.6.23"
  instance_class = "db.t2.micro"

  /* database configuration */
  name = "${var.db.name}"
  username = "${var.db.user}"
  password = "${var.db_passwd}"

  /* add instance to security group */
  vpc_security_group_ids = ["${aws_security_group.sg_database_access.id}"]
}

/* output the RDS endpoint and engine version */
output "db_endpoint" {
  value = "${aws_db_instance.database.endpoint}"
}
output "db_engine" {
  value = "${aws_db_instance.database.engine}"
}
output "db_engine_version" {
  value = "${aws_db_instance.database.engine_version}"
}

/* create the database security group */
resource "aws_security_group" "sg_database_access" {
  name = "sg_database_access"
  description = "Allow inbound access to database tier"

  ingress {
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
    security_groups = ["${aws_security_group.sg_utility_access.id}", "${aws_security_group.sg_web_access.id}"]
  }
}

/* output the group id */
output "sg_database_access_id" {
  value = "${aws_security_group.sg_database_access.id}"
}
