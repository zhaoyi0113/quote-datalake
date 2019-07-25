
resource "aws_s3_bucket" "bucket" {
  bucket = "${var.s3_bucket}"
}

resource "aws_s3_bucket" "athena-bucket" {
  bucket = "${var.athena-bucket}"
}

# resource "aws_s3_bucket_notification" "bucket_notification_movies" {
#   bucket = "${aws_s3_bucket.bucket.id}"
#   depends_on = [aws_s3_bucket.bucket]

#   lambda_function {
#     lambda_function_arn = "${aws_lambda_function.trigger_glue_crawler.arn}"
#     events              = ["s3:ObjectCreated:*"]
#     filter_prefix       = "movies/"
#   }
# }
