## define glue service role and attach policies
# resource "aws_iam_role" "glue" {
#   name               = "AWSGlueServiceRoleDefault"
#   assume_role_policy = <<EOF
# {
#     "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Action": "sts:AssumeRole",
#       "Principal": {
#         "Service": "glue.amazonaws.com"
#       },
#       "Effect": "Allow",
#       "Sid": ""
#     }
#   ]
# }
# EOF
# }

data "aws_iam_role" "AWSGlueServiceRoleDefault" {
  name = "AWSGlueServiceRoleDefault"
}

variable "glue_service_role" {
  default = "AWSGlueServiceRoleDefault"
}

variable "reddit_movie_etl_script" {
  default = "reddit_movie_etl.py"
}


resource "aws_iam_role_policy_attachment" "glue_service" {
  role       = "${var.glue_service_role}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}

resource "aws_iam_role_policy_attachment" "glue_service_s3" {
  role       = "${var.glue_service_role}"
  policy_arn = "${aws_iam_policy.s3_policy.arn}"
}

# glue catalog database
resource "aws_glue_catalog_database" "video" {
  name = "video"
}

# glue crawler
resource "aws_glue_crawler" "reddit_movie_crawler" {
  database_name = "${aws_glue_catalog_database.video.name}"
  name          = "${var.glue_crawler_name}"
  role          = "${var.glue_service_role}"
  table_prefix  = "reddit"
  classifiers   = ["${aws_glue_classifier.json_array.name}"]
  configuration = <<EOF
{
    "Version": 1.0,
    "Grouping": { "TableGroupingPolicy": "CombineCompatibleSchemas" }
}
EOF
  s3_target {
    path = "s3://${var.s3_bucket}/NetflixBestOf"
  }
  s3_target {
    path = "s3://${var.s3_bucket}/movies"
  }
}

# glue classifier
resource "aws_glue_classifier" "json_array" {
  name = "json_array"

  json_classifier {
    json_path = "$[*]"
  }
}

# glue job
resource "aws_glue_job" "reddit_movie_job" {
  name = "${var.glue_move_job_name}"
  role_arn = "${data.aws_iam_role.AWSGlueServiceRoleDefault.arn}"

  command {
    script_location = "s3://${var.s3_bucket}/${aws_s3_bucket_object.upload_glue_etl_script.key}"
  }
  default_arguments = {
    "--job-language" = "python"
    "--TempDir"= "s3://${var.s3_bucket}/temporary"
  }
  depends_on = [aws_s3_bucket_object.upload_glue_etl_script]
}

# upload spark script to s3 bucket
resource "aws_s3_bucket_object" "upload_glue_etl_script" {
  bucket = "${aws_s3_bucket.bucket.id}"
  key = "scripts/${var.reddit_movie_etl_script}"
  source = "src/datalake/glue/${var.reddit_movie_etl_script}"
  etag = "${filemd5("src/datalake/glue/${var.reddit_movie_etl_script}")}"
}
