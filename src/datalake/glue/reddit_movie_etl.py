import sys
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job

## @params: [JOB_NAME]
args = getResolvedOptions(sys.argv, ['JOB_NAME'])

sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)
job.init(args['JOB_NAME'], args)
## @type: DataSource
## @args: [database = "video", table_name = "redditmovies", transformation_ctx = "datasource0"]
## @return: datasource0
## @inputs: []
datasource0 = glueContext.create_dynamic_frame.from_catalog(database = "video", table_name = "redditmovies", transformation_ctx = "datasource0")
## @type: ApplyMapping
## @args: [mapping = [("approved_at_utc", "string", "approved_at_utc", "string"), ("selftext", "string", "selftext", "string"), ("author_fullname", "string", "author_fullname", "string"), ("saved", "boolean", "saved", "boolean"), ("mod_reason_title", "string", "mod_reason_title", "string"), ("gilded", "int", "gilded", "int"), ("clicked", "boolean", "clicked", "boolean"), ("title", "string", "title", "string"), ("link_flair_richtext", "array", "link_flair_richtext", "array"), ("subreddit_name_prefixed", "string", "subreddit_name_prefixed", "string"), ("hidden", "boolean", "hidden", "boolean"), ("pwls", "int", "pwls", "int"), ("link_flair_css_class", "string", "link_flair_css_class", "string"), ("downs", "int", "downs", "int"), ("thumbnail_height", "int", "thumbnail_height", "int"), ("hide_score", "boolean", "hide_score", "boolean"), ("name", "string", "name", "string"), ("quarantine", "boolean", "quarantine", "boolean"), ("link_flair_text_color", "string", "link_flair_text_color", "string"), ("author_flair_background_color", "string", "author_flair_background_color", "string"), ("subreddit_type", "string", "subreddit_type", "string"), ("ups", "int", "ups", "int"), ("total_awards_received", "int", "total_awards_received", "int"), ("media_embed", "struct", "media_embed", "struct"), ("thumbnail_width", "int", "thumbnail_width", "int"), ("author_flair_template_id", "string", "author_flair_template_id", "string"), ("is_original_content", "boolean", "is_original_content", "boolean"), ("user_reports", "array", "user_reports", "array"), ("secure_media", "struct", "secure_media", "struct"), ("is_reddit_media_domain", "boolean", "is_reddit_media_domain", "boolean"), ("is_meta", "boolean", "is_meta", "boolean"), ("category", "string", "category", "string"), ("secure_media_embed", "struct", "secure_media_embed", "struct"), ("link_flair_text", "string", "link_flair_text", "string"), ("can_mod_post", "boolean", "can_mod_post", "boolean"), ("score", "int", "score", "int"), ("approved_by", "string", "approved_by", "string"), ("thumbnail", "string", "thumbnail", "string"), ("edited", "double", "edited", "double"), ("author_flair_css_class", "string", "author_flair_css_class", "string"), ("author_flair_richtext", "array", "author_flair_richtext", "array"), ("gildings", "struct", "gildings", "struct"), ("post_hint", "string", "post_hint", "string"), ("content_categories", "string", "content_categories", "string"), ("is_self", "boolean", "is_self", "boolean"), ("mod_note", "string", "mod_note", "string"), ("created", "double", "created", "double"), ("link_flair_type", "string", "link_flair_type", "string"), ("wls", "int", "wls", "int"), ("banned_by", "string", "banned_by", "string"), ("author_flair_type", "string", "author_flair_type", "string"), ("domain", "string", "domain", "string"), ("allow_live_comments", "boolean", "allow_live_comments", "boolean"), ("selftext_html", "string", "selftext_html", "string"), ("likes", "string", "likes", "string"), ("suggested_sort", "string", "suggested_sort", "string"), ("banned_at_utc", "string", "banned_at_utc", "string"), ("view_count", "string", "view_count", "string"), ("archived", "boolean", "archived", "boolean"), ("no_follow", "boolean", "no_follow", "boolean"), ("is_crosspostable", "boolean", "is_crosspostable", "boolean"), ("pinned", "boolean", "pinned", "boolean"), ("over_18", "boolean", "over_18", "boolean"), ("preview", "struct", "preview", "struct"), ("all_awardings", "array", "all_awardings", "array"), ("media_only", "boolean", "media_only", "boolean"), ("can_gild", "boolean", "can_gild", "boolean"), ("spoiler", "boolean", "spoiler", "boolean"), ("locked", "boolean", "locked", "boolean"), ("author_flair_text", "string", "author_flair_text", "string"), ("visited", "boolean", "visited", "boolean"), ("num_reports", "string", "num_reports", "string"), ("distinguished", "string", "distinguished", "string"), ("subreddit_id", "string", "subreddit_id", "string"), ("mod_reason_by", "string", "mod_reason_by", "string"), ("removal_reason", "string", "removal_reason", "string"), ("link_flair_background_color", "string", "link_flair_background_color", "string"), ("id", "string", "id", "string"), ("is_robot_indexable", "boolean", "is_robot_indexable", "boolean"), ("report_reasons", "string", "report_reasons", "string"), ("num_crossposts", "int", "num_crossposts", "int"), ("num_comments", "int", "num_comments", "int"), ("send_replies", "boolean", "send_replies", "boolean"), ("whitelist_status", "string", "whitelist_status", "string"), ("contest_mode", "boolean", "contest_mode", "boolean"), ("mod_reports", "array", "mod_reports", "array"), ("author_patreon_flair", "boolean", "author_patreon_flair", "boolean"), ("author_flair_text_color", "string", "author_flair_text_color", "string"), ("permalink", "string", "permalink", "string"), ("parent_whitelist_status", "string", "parent_whitelist_status", "string"), ("stickied", "boolean", "stickied", "boolean"), ("url", "string", "url", "string"), ("subreddit_subscribers", "int", "subreddit_subscribers", "int"), ("created_utc", "double", "created_utc", "double"), ("discussion_type", "string", "discussion_type", "string"), ("media", "struct", "media", "struct"), ("is_video", "boolean", "is_video", "boolean"), ("_fetched", "boolean", "_fetched", "boolean"), ("comment_limit", "int", "comment_limit", "int"), ("comment_sort", "string", "comment_sort", "string"), ("_comments_by_id", "string", "_comments_by_id", "string"), ("link_flair_template_id", "string", "link_flair_template_id", "string"), ("crosspost_parent_list", "array", "crosspost_parent_list", "array"), ("crosspost_parent", "string", "crosspost_parent", "string"), ("media_metadata", "struct", "media_metadata", "struct")], transformation_ctx = "applymapping1"]
## @return: applymapping1
## @inputs: [frame = datasource0]
applymapping1 = ApplyMapping.apply(frame = datasource0, mappings = [("approved_at_utc", "string", "approved_at_utc", "string"), ("selftext", "string", "selftext", "string"), ("author_fullname", "string", "author_fullname", "string"), ("saved", "boolean", "saved", "boolean"), ("mod_reason_title", "string", "mod_reason_title", "string"), ("gilded", "int", "gilded", "int"), ("clicked", "boolean", "clicked", "boolean"), ("title", "string", "title", "string"), ("link_flair_richtext", "array", "link_flair_richtext", "array"), ("subreddit_name_prefixed", "string", "subreddit_name_prefixed", "string"), ("hidden", "boolean", "hidden", "boolean"), ("pwls", "int", "pwls", "int"), ("link_flair_css_class", "string", "link_flair_css_class", "string"), ("downs", "int", "downs", "int"), ("thumbnail_height", "int", "thumbnail_height", "int"), ("hide_score", "boolean", "hide_score", "boolean"), ("name", "string", "name", "string"), ("quarantine", "boolean", "quarantine", "boolean"), ("link_flair_text_color", "string", "link_flair_text_color", "string"), ("author_flair_background_color", "string", "author_flair_background_color", "string"), ("subreddit_type", "string", "subreddit_type", "string"), ("ups", "int", "ups", "int"), ("total_awards_received", "int", "total_awards_received", "int"), ("media_embed", "struct", "media_embed", "struct"), ("thumbnail_width", "int", "thumbnail_width", "int"), ("author_flair_template_id", "string", "author_flair_template_id", "string"), ("is_original_content", "boolean", "is_original_content", "boolean"), ("user_reports", "array", "user_reports", "array"), ("secure_media", "struct", "secure_media", "struct"), ("is_reddit_media_domain", "boolean", "is_reddit_media_domain", "boolean"), ("is_meta", "boolean", "is_meta", "boolean"), ("category", "string", "category", "string"), ("secure_media_embed", "struct", "secure_media_embed", "struct"), ("link_flair_text", "string", "link_flair_text", "string"), ("can_mod_post", "boolean", "can_mod_post", "boolean"), ("score", "int", "score", "int"), ("approved_by", "string", "approved_by", "string"), ("thumbnail", "string", "thumbnail", "string"), ("edited", "double", "edited", "double"), ("author_flair_css_class", "string", "author_flair_css_class", "string"), ("author_flair_richtext", "array", "author_flair_richtext", "array"), ("gildings", "struct", "gildings", "struct"), ("post_hint", "string", "post_hint", "string"), ("content_categories", "string", "content_categories", "string"), ("is_self", "boolean", "is_self", "boolean"), ("mod_note", "string", "mod_note", "string"), ("created", "double", "created", "double"), ("link_flair_type", "string", "link_flair_type", "string"), ("wls", "int", "wls", "int"), ("banned_by", "string", "banned_by", "string"), ("author_flair_type", "string", "author_flair_type", "string"), ("domain", "string", "domain", "string"), ("allow_live_comments", "boolean", "allow_live_comments", "boolean"), ("selftext_html", "string", "selftext_html", "string"), ("likes", "string", "likes", "string"), ("suggested_sort", "string", "suggested_sort", "string"), ("banned_at_utc", "string", "banned_at_utc", "string"), ("view_count", "string", "view_count", "string"), ("archived", "boolean", "archived", "boolean"), ("no_follow", "boolean", "no_follow", "boolean"), ("is_crosspostable", "boolean", "is_crosspostable", "boolean"), ("pinned", "boolean", "pinned", "boolean"), ("over_18", "boolean", "over_18", "boolean"), ("preview", "struct", "preview", "struct"), ("all_awardings", "array", "all_awardings", "array"), ("media_only", "boolean", "media_only", "boolean"), ("can_gild", "boolean", "can_gild", "boolean"), ("spoiler", "boolean", "spoiler", "boolean"), ("locked", "boolean", "locked", "boolean"), ("author_flair_text", "string", "author_flair_text", "string"), ("visited", "boolean", "visited", "boolean"), ("num_reports", "string", "num_reports", "string"), ("distinguished", "string", "distinguished", "string"), ("subreddit_id", "string", "subreddit_id", "string"), ("mod_reason_by", "string", "mod_reason_by", "string"), ("removal_reason", "string", "removal_reason", "string"), ("link_flair_background_color", "string", "link_flair_background_color", "string"), ("id", "string", "id", "string"), ("is_robot_indexable", "boolean", "is_robot_indexable", "boolean"), ("report_reasons", "string", "report_reasons", "string"), ("num_crossposts", "int", "num_crossposts", "int"), ("num_comments", "int", "num_comments", "int"), ("send_replies", "boolean", "send_replies", "boolean"), ("whitelist_status", "string", "whitelist_status", "string"), ("contest_mode", "boolean", "contest_mode", "boolean"), ("mod_reports", "array", "mod_reports", "array"), ("author_patreon_flair", "boolean", "author_patreon_flair", "boolean"), ("author_flair_text_color", "string", "author_flair_text_color", "string"), ("permalink", "string", "permalink", "string"), ("parent_whitelist_status", "string", "parent_whitelist_status", "string"), ("stickied", "boolean", "stickied", "boolean"), ("url", "string", "url", "string"), ("subreddit_subscribers", "int", "subreddit_subscribers", "int"), ("created_utc", "double", "created_utc", "double"), ("discussion_type", "string", "discussion_type", "string"), ("media", "struct", "media", "struct"), ("is_video", "boolean", "is_video", "boolean"), ("_fetched", "boolean", "_fetched", "boolean"), ("comment_limit", "int", "comment_limit", "int"), ("comment_sort", "string", "comment_sort", "string"), ("_comments_by_id", "string", "_comments_by_id", "string"), ("link_flair_template_id", "string", "link_flair_template_id", "string"), ("crosspost_parent_list", "array", "crosspost_parent_list", "array"), ("crosspost_parent", "string", "crosspost_parent", "string"), ("media_metadata", "struct", "media_metadata", "struct")], transformation_ctx = "applymapping1")
## @type: DataSink
## @args: [connection_type = "s3", connection_options = {"path": "s3://jzhao-datalake-test/glue_target/reddit_movie"}, format = "json", transformation_ctx = "datasink2"]
## @return: datasink2
## @inputs: [frame = applymapping1]
datasink2 = glueContext.write_dynamic_frame.from_options(frame = applymapping1, connection_type = "s3", connection_options = {"path": "s3://jzhao-datalake-test/glue_target/reddit_movie"}, format = "json", transformation_ctx = "datasink2")
job.commit()