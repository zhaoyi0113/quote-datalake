provider "aws" {
  profile    = "default"
  region     = "ap-southeast-2"
}

variable "runtime" {
  default = "python3.6"
}

resource "aws_lambda_function" "test_lambda" {
  filename      = "crawler/dist/handler.zip"
  function_name = "quote-crawler"
  role          = "arn:aws:iam::773592622512:role/LambdaRole"
  handler       = "handler.handler"

  runtime = "${var.runtime}"

  environment {
    variables = {
      foo = "bar"
    }
  }
}