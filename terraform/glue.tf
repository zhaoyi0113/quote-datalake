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

resource "aws_iam_role_policy_attachment" "glue_service" {
  role       = "AWSGlueServiceRoleDefault"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}

resource "aws_iam_role_policy_attachment" "glue_service_s3" {
  role       = "AWSGlueServiceRoleDefault"
  policy_arn = "${aws_iam_policy.s3_policy.arn}"
}

# glue catalog database
resource "aws_glue_catalog_database" "video" {
  name = "video"
}

# glue crawler
resource "aws_glue_crawler" "reddit_movie_crawler" {
  database_name = "${aws_glue_catalog_database.video.name}"
  name          = "reddit_movie"
  role          = "AWSGlueServiceRoleDefault"
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
