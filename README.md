# Data lake pipeline

This repo is to demonstrate how data lake works in AWS platform as severless platform. The idea is to create a web crawler to load data from any sources and save them in S3 bucket as original data lake. Then trigger AWS glue to transform the data to database with a defined schema which make it available for querying and analysing by AWS Athena.

![Data lake pipeline](https://github.com/zhaoyi0113/simple-datalake/blob/master/images/datalake_pipeline.png)

## Web Crawler

The web crawler is implemented in `praw`, a `Python` library used to crawl data from reddit. It is running inside a `lambda` triggered by `cloudwatch` scheduler and generates json data based on the query keyword from cloudwatch event and save them on s3 bucket. The source code `newpost_monitor.py` is the implementation.

## Glue Crawler

Glue crawler is different than the `web crawler`. It is actually a piece of logic to discover the data schema from your s3 bucket. It works like a crawler to dig into your bucket and use customised and build-in classifier to find the schema. The customised classifier is defined in `Terraform` configuration file: `glue.tf`. The output of this step is a catalog saved in Glue database table for later analyse in `Athena`.

## Glue Job

Glue job is the next step after `Crawler`, it is used as ETL in the data pipeline. The ETL script is defined in `Python spark`, `reddit_movie_etl.py` file. Basically, it scans your data from original s3 bucket and transfer the data into a different schema. The mapping process can be as simple as renaming field names or convert data tpyes. It can also be something like restructuring the raw data into a completely different format like `parquet`. The new schema catalog is saved in a different s3 bucket named by the environment variable `TF_VAR_athena-bucket`.

## Lambda & Cloudwatch

You might see there are a few `lambda` functions and `cloudwatch` listeners on the above diagram. They are used to trigger the tasks in the pipeline. Because AWS services may not be able to trigger other serivces directly. Sometimes we have to create a `rule` in `cloudwatch` to trigger a `lambda` which to trigger the next service.

## Infrastructure

The cloud infrastructure is managed by `Terraform`.

## How to run

In order to run this demo, you will need to install:

### command line tool

- terraform
- python
- aws
- docker

### credentials

- configure aws credential under `~/.aws/credential` and `~/.aws/config`.
- create an app in `reddit dev` account and set up the credential in environment variables `TF_VAR_praw_client_id` and `TF_VAR_praw_client_secret`. There are used by the web crawler to crawl data from reddit web site.

### Environment Variables

- TF_VAR_s3_bucket :    The s3 bucket to be used as data lake storage
- TF_VAR_athena-bucket: The s3 bucket to save Athena query result
- TF_VAR_praw_client_id:    reddit app client id
- TF_VAR_praw_client_secret:    reddit app client secret

### Build Step

```script
- sh bin/build_lambda_layer.sh # build python dependencies as a lambda layer
- sh bin/deploy.sh              # package python code and deploy to AWS via Terraform
```

## Resources

- https://medium.com/@zhaoyi0113/terraform-step-by-step-tutorial-e29e165407b3
