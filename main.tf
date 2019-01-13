# Providers

provider "aws" {
	access_key = "${var.aws_access_key}"
	secret_key = "${var.aws_secret_key}"
  region     = "${var.aws_region}"
}

# Data
data "aws_vpc" "default" {}
data "aws_availability_zones" "available" {}
//data "aws_subnet_ids" "all" {
//vpc_id = "${data.aws_vpc.default.id}"
//}

resource "aws_security_group" "mysql_secgroup" {
	vpc_id = "${data.aws_vpc.default.id}"

	ingress {
		from_port = "${var.mysql_port}"
		to_port = "${var.mysql_port}"
		protocol = "tcp"
		cidr_blocks = ["0.0.0.0/0"]
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
  username                        = "${var.username}"
  password                        = "${var.password}"
  publicly_accessible             = "${var.publicly_accessible}"
  storage_encrypted               = "${var.storage_encrypted}"
  apply_immediately               = "${var.apply_immediately}"
}

# INSTANCES #
resource "aws_instance" "nodejs" {
  ami           = "${var.ec2_instance_ami_id}"
  instance_type = "${var.ec2_instance_type}"
  key_name        = "${var.key_name}"

  connection {
    user        = "${var.ec2_user}"
    private_key = "${file(var.private_key_path)}"
  }

  provisioner "remote-exec" {
    inline = [
      "curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.32.0/install.sh | bash",
      ". ~/.nvm/nvm.sh",
      "nvm install 4.4.5",
      "git clone https://github.com/ashishranjan1457/rest-crud.git",
      "cd rest-crud",
      "npm install",
      "nohup node server.js &"
    ]
  }
}
