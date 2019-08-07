variable "runtime" {
  default = "python3.6"
}

variable "project_name" {
  default = "datalake"
}

variable "env" {
  default = "dev"
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

variable "glue_target_crawler_name" {
  default = "target_movie_crawler"
}


variable "lambda_python_deps_file" {
  default = "lambda_layer.zip"
}

variable "glue_movie_job_name" {
  default = "reddit_movies"
}

variable "athena_catalog_db_name" {
  default = "video"
}
