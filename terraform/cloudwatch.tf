resource "aws_cloudwatch_event_rule" "every_one_minutes" {
  name                = "reddit_monitor_scheduler"
  description         = "Fires every one minutes"
  schedule_expression = "rate(30 minutes)"
}

resource "aws_cloudwatch_event_target" "search_movies_reddit_every_one_minutes" {
  rule      = "${aws_cloudwatch_event_rule.every_one_minutes.name}"
  target_id = "search_movies_reddit"
  arn       = "${aws_lambda_function.reddit_montior.arn}"
  input     = "{\"topic\": \"movies\"}"
}

resource "aws_cloudwatch_event_target" "search_netflixbestof_reddit_every_one_minutes" {
  rule      = "${aws_cloudwatch_event_rule.every_one_minutes.name}"
  target_id = "search_netflixbestof_reddit"
  arn       = "${aws_lambda_function.reddit_montior.arn}"
  input     = "{\"topic\": \"NetflixBestOf\"}"
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_check_reddit" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.reddit_montior.function_name}"
  principal     = "events.amazonaws.com"
  source_arn    = "${aws_cloudwatch_event_rule.every_one_minutes.arn}"
}

## add event to listen on glue crawler event
resource "aws_cloudwatch_event_rule" "crawler" {
  name        = "glue_crawler_log"
  description = "Capture Glue Crawler complete"

  event_pattern = <<PATTERN
{
  "detail-type": [
        "Glue Crawler State Change"
    ],
    "source": [
        "aws.glue"
    ]
}
PATTERN
}

resource "aws_cloudwatch_event_target" "trigger_glue_job_lambda" {
  rule = "${aws_cloudwatch_event_rule.crawler.name}"
  target_id = "SendToLambda"
  arn = "${aws_lambda_function.trigger_glue_job.arn}"
}

resource "aws_cloudwatch_event_target" "log_glue_crawler_result" {
  rule = "${aws_cloudwatch_event_rule.crawler.name}"
  target_id = "LogCrawler"
  arn = "${substr(aws_cloudwatch_log_group.grue_crawler_log_group.arn, 0, length(aws_cloudwatch_log_group.grue_crawler_log_group.arn) - 2)}"
}

resource "aws_cloudwatch_log_group" "grue_crawler_log_group" {
  name = "crawler_log"
  tags = {
    Application = "reddit_movies"
  }
}
