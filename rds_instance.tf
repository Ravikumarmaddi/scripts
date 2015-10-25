resource "aws_db_instance" "database" {
  identifier = "${var.instance_name.database}"
  allocated_storage = 5
  engine = "mysql"
  engine_version = "5.6.23"
  instance_class = "db.t2.micro"
  name = "${var.instance_name.database}"
  username = "${var.dbuser}"
  password = "${var.dbpass}"
  vpc_security_group_ids = ["${aws_security_group.sg_database_access.id}"]
}

output "db_instance_id" {
  value = "${aws_db_instance.database.id}"
}
output "db_endpoint" {
  value = "${aws_db_instance.database.endpoint}"
}
output "db_engine" {
  value = "${aws_db_instance.database.engine}"
}
output "db_engine_version" {
  value = "${aws_db_instance.database.engine_version}"
}

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
