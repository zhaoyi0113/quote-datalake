# Data lake pipeline

This repo is to demonstrate how data lake works in AWS platform as severless platform. The idea is to create a web crawler to load data from any sources and save them in S3 bucket as original data lake. Then trigger AWS glue to transform the data to database with a defined schema which make it available for querying and analysing by AWS Athena.

## Crawler

Web crawler is implemented in `python`.

## Infrastructure

The cloud infrastructure is managed by `Terraform`.

# Resources

- https://medium.com/@zhaoyi0113/terraform-step-by-step-tutorial-e29e165407b3