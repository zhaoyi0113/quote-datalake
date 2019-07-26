import praw
import numpy as np
import pandas as pd
from datalake.utils import utils
import time
import logging

LIMIT = 100

logger = logging.getLogger()
logger.setLevel(logging.DEBUG)

def handler(event, context):
    reddit = utils.createReddit()
    topic = 'movies'
    if 'topic' in event:
        topic = event['topic']
    check_new_posts(reddit, topic)


def check_new_posts(reddit, topic):
    new_posts = []
    new_posts_id = []
    for post in reddit.subreddit(topic).new(limit=LIMIT):
        if post.name not in seen_posts:
            seen_posts.append(post.name)
            new_posts.append(post)
            new_posts_id.append(post.name)
    logger.info('check new posts:' + str(len(new_posts)))
    if len(new_posts) > 0:
        existed_names = utils.query_submission_id(new_posts_id)
        filtered = list(filter(lambda n: filter(
            lambda x: x != n.name, existed_names), new_posts))
        logger.info('filtered ' + str(len(filtered)))
        notify(filtered, topic)


def notify(subs, topic):
    logger.info('send notify for ' + str(len(subs)) + ' submissions')
    utils.upload_subs_to_s3(subs, topic)


seen_posts = []

if __name__ == '__main__':
    while True:
        handler({'topic': 'news'}, None)
        time.sleep(5)
