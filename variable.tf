# Variables

variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "aws_region" {
  default = "us-east-1"
}
variable "private_key_path" {}
variable "key_name" {}
variable "mysql_port" {}
variable "rds_storage" {}
variable "rds_instance_type" {}
variable "storage_type" {}
variable "multi_az" {}
variable "publicly_accessible" {}
variable "storage_encrypted" {}
variable "skip_final_snapshot" {}
variable "rds_identifier" {}
variable "apply_immediately" {}
variable "database" {}
variable "username" {}
variable "password" {}
variable "snapshot_identifier" {}
variable "ec2_instance_ami_id" {}
variable "ec2_instance_type" {}
variable "ec2_user" {}
