resource "aws_kms_key" "praw_client_id" {
  description = "Praw client ID"
}

resource "aws_kms_key" "praw_client_secret" {
  description = "Praw client secret"
}

resource "aws_kms_alias" "praw_client_id" {
  name = "alias/praw_client_id"
  target_key_id = "${aws_kms_key.praw_client_id.key_id}"
}

resource "aws_kms_alias" "praw_client_secret" {
  name = "alias/praw_client_secret"
  target_key_id = "${aws_kms_key.praw_client_secret.key_id}"
}
