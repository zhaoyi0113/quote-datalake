# Data lake pipeline

This repo is to demonstrate how data lake works in AWS platform as severless platform. The idea is to create a web crawler to load data from any sources and save them in S3 bucket as original data lake. Then trigger AWS glue to transform the data to database with a defined schema which make it available for querying and analysing by AWS Athena.

## Crawler

Web crawler is implemented in `python`.

## Infrastructure

The cloud infrastructure is managed by `Terraform`.

## How to run

In order to run this demo, you will need to install:

### command line tool

- terraform
- python
- aws

### credentials

- configure aws credential under `~/.aws/credential` and `~/.aws/config`.
- create an app in `reddit dev` account and set up the credential in environment variables `TF_VAR_praw_client_id` and `TF_VAR_praw_client_secret`. There are used by the web crawler to crawl data from reddit web site.

### Environment Variables

- TF_VAR_s3_bucket :    The s3 bucket to be used as data lake storage
- TF_VAR_athena-bucket: The s3 bucket to save Athena query result

## Resources

- https://medium.com/@zhaoyi0113/terraform-step-by-step-tutorial-e29e165407b3