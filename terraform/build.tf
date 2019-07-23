##
# zip the code and upload to s3 bucket
##

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
  bucket = "${var.s3_bucket}"
  key    = "${local.s3-crawler-deploy-key}"
  source = "${data.archive_file.zipit.output_path}"

  # The filemd5() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the md5() function and the file() function:
  # etag = "${md5(file("path/to/file"))}"
  # etag = "${filemd5("path/to/file")}"
}
