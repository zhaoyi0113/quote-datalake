##
# Lambda
##
resource "aws_lambda_function" "test_lambda" {
  s3_bucket = "${var.s3_bucket}"
  s3_key    = "${aws_s3_bucket_object.file_upload.key}"
  function_name    = "quote-crawler"
  role             = "${aws_iam_role.role.arn}"
  handler          = "handler.handler"
  source_code_hash = "${data.archive_file.zipit.output_base64sha256}"
  runtime          = "${var.runtime}"
  timeout          = 180
}

resource "aws_lambda_function" "praw_crawler" {
  s3_bucket        = "${var.s3_bucket}"
  s3_key           = "${aws_s3_bucket_object.file_upload.key}"
  function_name    = "praw_crawler"
  role             = "${aws_iam_role.role.arn}"
  handler          = "praw_crawler.handler"
  source_code_hash = "${data.archive_file.zipit.output_base64sha256}"
  runtime          = "${var.runtime}"
  timeout          = 180
  environment {
    variables = {
      praw_client_id = "${var.praw_client_id}"
      praw_client_secret = "${var.praw_client_secret}"
    }
  }
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

#Created Policy for IAM Role
resource "aws_iam_policy" "iam_policy" {
  name = "lambda_access-policy"
  description = "IAM Policy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
            "Effect": "Allow",
            "Action": [
                "s3:ListAllMyBuckets",
                "s3:GetBucketLocation"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": "s3:*",
            "Resource": [
                "arn:aws:s3:::${var.s3_bucket}",
                "arn:aws:s3:::${var.s3_bucket}/*"
            ]
        },
        {
          "Action": [
            "autoscaling:Describe*",
            "cloudwatch:*",
            "logs:*",
            "sns:*"
          ],
          "Effect": "Allow",
          "Resource": "*"
        }
  ]
}
  EOF
}

# attach IAM role and the policy
resource "aws_iam_role_policy_attachment" "iam-policy-attach" {
  role       = "${aws_iam_role.role.name}"
  policy_arn = "${aws_iam_policy.iam_policy.arn}"
}
