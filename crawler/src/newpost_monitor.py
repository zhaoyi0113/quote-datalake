import praw
import numpy as np
import pandas as pd
import boto3
from utils import createReddit, createDataframeFromSub, upload_subs_to_s3
import time

def handler(event, context):
    reddit = createReddit()
    check_new_posts(reddit, 'movies')

def check_new_posts(reddit, sub):
    new_posts = []
    for post in reddit.subreddit(sub).new(limit=10):
        if post.id not in seen_posts:
            seen_posts.append(post.id)
            new_posts.append(post)
    print('check new posts:', len(new_posts))
    if len(new_posts) > 0:
        notify(new_posts)

def notify(subs):
    print('send notify for ', len(subs), ' submissions')
    upload_subs_to_s3(subs)

seen_posts = []

if __name__ == '__main__':
    while True:
        handler(None, None)
        time.sleep(5)
