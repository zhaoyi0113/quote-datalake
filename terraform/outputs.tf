output "s3_build_artifact" {
    value = "${aws_s3_bucket_object.file_upload.key}"
}