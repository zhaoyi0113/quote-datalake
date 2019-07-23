provider "aws" {
  profile = "default"
  region  = "ap-southeast-2"
  #   skip_credentials_validation = true
  #   skip_metadata_api_check     = true

  #   endpoints {
  #     lambda = "http://localhost:4574"
  #   }
}

variable "runtime" {
  default = "python3.6"
}
variable "region" {
  default = "ap-southeast-2"
}
variable "s3-bucket" {
  default = "jzhao-datalake-test"
}


variable "crawler_packaged_file" {
  default = "crawler/dist/deploy.zip"
}

variable "lambda_access" {
  default = "lambda_access"
}

locals {
  s3-crawler-deploy-key = "crawler/deploy-${timestamp()}.zip"
}

##
# Archive and upload to s3
##
data "archive_file" "zipit" {
  type        = "zip"
  source_dir  = "crawler/dist"
  output_path = "${var.crawler_packaged_file}"
}

resource "aws_s3_bucket_object" "file_upload" {
  bucket = "${var.s3-bucket}"
  key    = "${local.s3-crawler-deploy-key}"
  source = "${data.archive_file.zipit.output_path}"

  # The filemd5() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the md5() function and the file() function:
  # etag = "${md5(file("path/to/file"))}"
  # etag = "${filemd5("path/to/file")}"
}

##
# Lambda
##
resource "aws_lambda_function" "test_lambda" {
  # filename         = "crawler/dist/deploy.zip"
  s3_bucket = "${var.s3-bucket}"
  s3_key    = "${aws_s3_bucket_object.file_upload.key}"
  # source_code_hash = "${filebase64sha256("file.zip")}"
  function_name    = "quote-crawler"
  role             = "${aws_iam_role.role.arn}"
  handler          = "handler.handler"
  source_code_hash = "${data.archive_file.zipit.output_base64sha256}"
  runtime          = "${var.runtime}"
  timeout          = 180

  environment {
    variables = {
      foo = "bar"
    }
  }
}

resource "aws_lambda_function" "praw_crawler" {
  # filename         = "crawler/dist/deploy.zip"
  s3_bucket        = "${var.s3-bucket}"
  s3_key           = "${aws_s3_bucket_object.file_upload.key}"
  function_name    = "praw_crawler"
  role             = "${aws_iam_role.role.arn}"
  handler          = "praw_crawler.handler"
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
# API Gateway
##
resource "aws_api_gateway_method" "method" {
  rest_api_id   = "${aws_api_gateway_rest_api.api.id}"
  resource_id   = "${aws_api_gateway_resource.resource.id}"
  http_method   = "ANY"
  authorization = "NONE"
  request_parameters = {
    "method.request.path.proxy" = true
  }
}

resource "aws_api_gateway_integration" "integration" {
  rest_api_id             = "${aws_api_gateway_rest_api.api.id}"
  resource_id             = "${aws_api_gateway_resource.resource.id}"
  http_method             = "${aws_api_gateway_method.method.http_method}"
  integration_http_method = "ANY"
  type                    = "AWS_PROXY"
  uri                     = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/${aws_lambda_function.test_lambda.arn}/invocations"

  request_parameters = {
    "integration.request.path.proxy" = "method.request.path.proxy"
  }
}

resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.test_lambda.function_name}"
  principal     = "apigateway.amazonaws.com"

  # More: http://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-control-access-using-iam-policies-to-invoke-api.html
  # source_arn = "arn:aws:execute-api:${var.myregion}:${var.accountId}:${aws_api_gateway_rest_api.api.id}/*/${aws_api_gateway_method.method.http_method}${aws_api_gateway_resource.resource.path}"
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
                "arn:aws:s3:::${var.s3-bucket}",
                "arn:aws:s3:::${var.s3-bucket}/*"
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
