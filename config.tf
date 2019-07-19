provider "aws" {
  profile    = "default"
  region     = "ap-southeast-2"

#   endpoints {
#       lambda = "http://localhost:4567"
#   }
}

variable "runtime" {
  default = "python3.6"
}

data "archive_file" "zipit" {
    type        = "zip"
    source_dir  = "crawler/dist"
    output_path = "crawler/dist/deploy.zip"
}
resource "aws_lambda_function" "test_lambda" {
  filename      = "crawler/dist/deploy.zip"
  function_name = "quote-crawler"
  role          = "arn:aws:iam::773592622512:role/LambdaRole"
  handler       = "handler.handler"
  source_code_hash = "${data.archive_file.zipit.output_base64sha256}"
  runtime = "${var.runtime}"

  environment {
    variables = {
      foo = "bar"
    }
  }
}