variable "runtime" {
  default = "python3.6"
}
variable "region" {
  default = "ap-southeast-2"
}
variable "s3_bucket" {
  default = "datalake-demo-jzhao"
}

variable "athena-bucket" {
  default = "athena-datalake"
}

variable "crawler_packaged_file" {
  default = "crawler/dist/deploy.zip"
}

variable "lambda_access" {
  default = "lambda_access"
}

variable "praw_client_id" {
  
}

variable "praw_client_secret" {
  
}

variable "lambda_timeout" {
  default = 900
}


