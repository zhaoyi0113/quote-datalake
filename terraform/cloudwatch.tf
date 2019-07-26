resource "aws_cloudwatch_event_rule" "every_one_minutes" {
    name = "reddit_monitor_scheduler"
    description = "Fires every one minutes"
    schedule_expression = "rate(2 minutes)"
}

resource "aws_cloudwatch_event_target" "search_movies_reddit_every_one_minutes" {
    rule = "${aws_cloudwatch_event_rule.every_one_minutes.name}"
    target_id = "search_movies_reddit"
    arn = "${aws_lambda_function.reddit_montior.arn}"
    input = "{\"topic\": \"movies\"}"
}

resource "aws_cloudwatch_event_target" "search_netflixbestof_reddit_every_one_minutes" {
    rule = "${aws_cloudwatch_event_rule.every_one_minutes.name}"
    target_id = "search_netflixbestof_reddit"
    arn = "${aws_lambda_function.reddit_montior.arn}"
    input = "{\"topic\": \"NetflixBestOf\"}"
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_check_reddit" {
    statement_id = "AllowExecutionFromCloudWatch"
    action = "lambda:InvokeFunction"
    function_name = "${aws_lambda_function.reddit_montior.function_name}"
    principal = "events.amazonaws.com"
    source_arn = "${aws_cloudwatch_event_rule.every_one_minutes.arn}"
}
