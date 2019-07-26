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
  default = "src/dist/deploy.zip"
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

variable "glue_crawler_name" {
  default = "reddit_movie"
}

variable "lambda_python_deps_file" {
  default = "lambda_layer.zip"
}

variable "glue_move_job_name" {
  default = "reddit_movies"
}
