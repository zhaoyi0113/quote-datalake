##
# Lambda
##
# resource "aws_lambda_function" "test_lambda" {
#   s3_bucket        = "${var.s3_bucket}"
#   s3_key           = "${aws_s3_bucket_object.file_upload.key}"
#   function_name    = "quote-crawler"
#   role             = "${aws_iam_role.role.arn}"
#   handler          = "datalake.lambdas.handler.handler"
#   source_code_hash = "${data.archive_file.zipit.output_base64sha256}"
#   runtime          = "${var.runtime}"
#   timeout          = "${var.lambda_timeout}"
#   layers           = ["${aws_lambda_layer_version.lambda_python_deps_layer.arn}"]
# }

# resource "aws_lambda_function" "praw_crawler" {
#   s3_bucket        = "${var.s3_bucket}"
#   s3_key           = "${aws_s3_bucket_object.file_upload.key}"
#   function_name    = "praw_crawler"
#   role             = "${aws_iam_role.role.arn}"
#   handler          = "datalake.lambdas.praw_crawler.handler"
#   source_code_hash = "${data.archive_file.zipit.output_base64sha256}"
#   runtime          = "${var.runtime}"
#   layers           = ["${aws_lambda_layer_version.lambda_python_deps_layer.arn}"]
#   timeout          = "${var.lambda_timeout}"
#   environment {
#     variables = {
#       praw_client_id     = "${var.praw_client_id}"
#       praw_client_secret = "${var.praw_client_secret}"
#     }
#   }
# }

resource "aws_lambda_function" "reddit_montior" {
  s3_bucket        = "${var.s3_bucket}"
  s3_key           = "${aws_s3_bucket_object.file_upload.key}"
  function_name    = "reddit_monitor"
  role             = "${aws_iam_role.role.arn}"
  handler          = "datalake.lambdas.newpost_monitor.handler"
  source_code_hash = "${data.archive_file.zipit.output_base64sha256}"
  runtime          = "${var.runtime}"
  timeout          = "${var.lambda_timeout}"
  memory_size      = "512"
  layers           = ["${aws_lambda_layer_version.lambda_python_deps_layer.arn}"]
  environment {
    variables = {
      praw_client_id     = "${var.praw_client_id}"
      praw_client_secret = "${var.praw_client_secret}"
      env                = "${var.env}"
      project_name       = "${var.project_name}"
    }
  }
}

resource "aws_lambda_function" "trigger_glue_crawler" {
  s3_bucket        = "${var.s3_bucket}"
  s3_key           = "${aws_s3_bucket_object.file_upload.key}"
  function_name    = "trigger_glue_crawler"
  layers           = ["${aws_lambda_layer_version.lambda_python_deps_layer.arn}"]
  role             = "${aws_iam_role.role.arn}"
  handler          = "datalake.lambdas.trigger_glue_crawler.handler"
  source_code_hash = "${data.archive_file.zipit.output_base64sha256}"
  runtime          = "${var.runtime}"
  timeout          = 180
  environment {
    variables = {
      glue_crawler_name        = "${var.glue_crawler_name}"
      glue_target_crawler_name = "${var.glue_target_crawler_name}"
    }
  }
}

resource "aws_lambda_function" "trigger_glue_job" {
  s3_bucket        = "${var.s3_bucket}"
  s3_key           = "${aws_s3_bucket_object.file_upload.key}"
  function_name    = "trigger_glue_job"
  layers           = ["${aws_lambda_layer_version.lambda_python_deps_layer.arn}"]
  role             = "${aws_iam_role.role.arn}"
  handler          = "datalake.lambdas.trigger_glue_job.handler"
  source_code_hash = "${data.archive_file.zipit.output_base64sha256}"
  runtime          = "${var.runtime}"
  timeout          = 180
}

resource "aws_api_gateway_rest_api" "api" {
  name        = "quote-api-gateway"
  description = "Quote Datalake API Gateway"
}

resource "aws_api_gateway_resource" "resource" {
  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
  parent_id   = "${aws_api_gateway_rest_api.api.root_resource_id}"
  path_part   = "resource"
}

##
# Lambda IAM role
##
resource "aws_iam_role" "role" {
  name = "${var.lambda_access}-role"
  path = "/"

  assume_role_policy = <<EOF
{

  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

# attach IAM role and the policy
resource "aws_iam_role_policy_attachment" "iam-policy-attach" {
  role = "${aws_iam_role.role.name}"
  policy_arn = "${aws_iam_policy.iam_policy.arn}"
}

resource "aws_iam_role_policy_attachment" "iam-athena-policy-attach" {
  role = "${aws_iam_role.role.name}"
  policy_arn = "${aws_iam_policy.athena_policy.arn}"
}

resource "aws_iam_role_policy_attachment" "iam-glue-policy-attach" {
  role = "${aws_iam_role.role.name}"
  policy_arn = "${aws_iam_policy.glue_policy.arn}"
}


resource "aws_lambda_permission" "allow_bucket_trigger_lambda" {
  statement_id = "AllowExecutionFromS3Bucket"
  action = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.trigger_glue_crawler.arn}"
  principal = "s3.amazonaws.com"
  source_arn = "${aws_s3_bucket.bucket.arn}"
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = "${aws_s3_bucket.bucket.id}"

  lambda_function {
    lambda_function_arn = "${aws_lambda_function.trigger_glue_crawler.arn}"
    events = ["s3:ObjectCreated:*"]
    filter_prefix = "movies/"
  }

  lambda_function {
    lambda_function_arn = "${aws_lambda_function.trigger_glue_crawler.arn}"
    events = ["s3:ObjectCreated:*"]
    filter_prefix = "NetflixBestOf/"
  }
}

resource "aws_lambda_layer_version" "lambda_python_deps_layer" {
  s3_bucket = "${var.s3_bucket}"
  s3_key = "${aws_s3_bucket_object.python_layer_file_upload.key}"
  layer_name = "lambda_python_deps_layer"
  compatible_runtimes = ["${var.runtime}"]
}

resource "aws_s3_bucket_object" "python_layer_file_upload" {
  bucket = "${var.s3_bucket}"
  key = "${aws_s3_bucket_object.deploy_folder.key}/${var.lambda_python_deps_file}"
  source = "build/${var.lambda_python_deps_file}"
  etag = "${filemd5("build/${var.lambda_python_deps_file}")}"
}
