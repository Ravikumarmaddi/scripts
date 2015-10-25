resource "aws_db_instance" "database" {
  identifier = "${var.instance_name.database}"
  allocated_storage = 5
  engine = "mysql"
  engine_version = "5.6.23"
  instance_class = "db.t2.micro"
  name = "${var.instance_name.database}"
  username = "${var.db.user}"
  password = "${var.db.pass}"
  db_subnet_group_name = "sng_database_access"
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
