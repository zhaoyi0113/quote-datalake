resource "aws_ssm_parameter" "param_s3_bucket" {
  name  = "/${var.project_name}/${var.env}/s3_bucket"
  type  = "String"
  value = "${aws_s3_bucket.bucket.id}"
}

resource "aws_ssm_parameter" "param_s3_athena_bucket" {
  name  = "/${var.project_name}/${var.env}/athena_bucket"
  type  = "String"
  value = "${aws_s3_bucket.athena-bucket.id}"
}

resource "aws_ssm_parameter" "param_athena_catalog_db_name" {
  name  = "/${var.project_name}/${var.env}/athena_catalog_db_name"
  type  = "String"
  value = "${var.athena_catalog_db_name}"
}

resource "aws_ssm_parameter" "param_praw_client_id" {
  name  = "/${var.project_name}/${var.env}/praw_client_id"
  type  = "SecureString"
  value = "${var.praw_client_id}"
  key_id = "${aws_kms_key.praw_client_id.key_id}"
}

resource "aws_ssm_parameter" "param_praw_client_secret" {
  name  = "/${var.project_name}/${var.env}/praw_client_secret"
  type  = "SecureString"
  value = "${var.praw_client_secret}"
  key_id = "${aws_kms_key.praw_client_secret.key_id}"
}