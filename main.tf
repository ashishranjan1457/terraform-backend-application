# Providers

provider "aws" {
	access_key = "${var.aws_access_key}"
	secret_key = "${var.aws_secret_key}"
  region     = "${var.aws_region}"
}

# Data
data "aws_vpc" "default" {}
data "aws_availability_zones" "available" {}

# Resources

resource "aws_security_group" "allow_all" {
  description = "Allow all inbound traffic"

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

	egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_all"
  }
}


resource "aws_security_group" "mysql_secgroup" {
	vpc_id = "${data.aws_vpc.default.id}"
	description = "Allow traffic for mysql port"

	ingress {
		from_port = "${var.mysql_port}"
		to_port = "${var.mysql_port}"
		protocol = "tcp"
		cidr_blocks = ["0.0.0.0/0"]
	}

	tags = {
    Name = "mysql_security_group"
  }
}

resource "aws_db_instance" "app_database" {
  instance_class                  = "${var.rds_instance_type}"
  engine                          = "mysql"
  vpc_security_group_ids          = ["${aws_security_group.mysql_secgroup.id}"]
  identifier                      = "${var.rds_identifier}"
  skip_final_snapshot             = "${var.skip_final_snapshot}"
  allocated_storage               = "${var.rds_storage}"
  storage_type                    = "${var.storage_type}"
  snapshot_identifier             = "${var.snapshot_identifier}"
  multi_az                        = "${var.multi_az}"
  name                            = "${var.database}"
  username                        = "${var.db_username}"
  password                        = "${var.db_password}"
  publicly_accessible             = "${var.publicly_accessible}"
  storage_encrypted               = "${var.storage_encrypted}"
  apply_immediately               = "${var.apply_immediately}"

	tags = {
    Name = "rds_mysql_database"
  }

}

# INSTANCES #
resource "aws_instance" "nodejs" {
  ami           = "${var.ec2_instance_ami_id}"
  instance_type = "${var.ec2_instance_type}"
  key_name        = "${var.key_name}"
	vpc_security_group_ids = ["${aws_security_group.allow_all.id}"]

  connection {
    user        = "${var.ec2_user}"
    private_key = "${file(var.private_key_path)}"
  }

	tags = {
    Name = "nodejs_server"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt update",
      "sudo apt install -y nodejs npm",
      "git clone https://github.com/ashishranjan1457/rest-crud.git",
      "cd rest-crud",
			"export DB_ENDPOINT=${aws_db_instance.app_database.address}",
			"export DB_USERNAME=${var.db_username}",
      "export DB_PASSWORD=${var.db_password}",
			"envsubst < server.js.template > server.js",
      "npm install",
      "nohup nodejs server.js > /tmp/test.txt 2>&1 </dev/null &"
    ]
  }
}
