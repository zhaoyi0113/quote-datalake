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
data "archive_file" "zipit" {
  type        = "zip"
  source_dir  = "crawler/dist"
  output_path = "crawler/dist/deploy.zip"
}
resource "aws_lambda_function" "test_lambda" {
  filename         = "crawler/dist/deploy.zip"
  function_name    = "quote-crawler"
  role             = "arn:aws:iam::773592622512:role/LambdaRole"
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
  filename         = "crawler/dist/deploy.zip"
  function_name    = "praw_crawler"
  role             = "arn:aws:iam::773592622512:role/LambdaRole"
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
  #   source_arn = "arn:aws:execute-api:${var.myregion}:${var.accountId}:${aws_api_gateway_rest_api.api.id}/*/${aws_api_gateway_method.method.http_method}${aws_api_gateway_resource.resource.path}"
}
