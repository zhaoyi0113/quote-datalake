import praw
import numpy as np
import pandas as pd
import boto3
from datetime import datetime
from io import StringIO
import os
from utils import utils
import json

LIMIT = 1

reddit = praw.Reddit(client_id=os.environ['praw_client_id'],
                     client_secret=os.environ['praw_client_secret'],
                     user_agent='lambda')


def handler(event, context):
    print(reddit.read_only)
    info = []
    reddit.config.store_json_result = True
    topics = reddit.subreddit('NetflixBestOf').hot(limit=LIMIT)
    # for submission in topics:
        # print(str(vars(submission)))
        # row = np.array([submission.id, submission.name, submission.num_comments,
        #                 submission.score, submission.title, submission.url, submission.created_utc])
        # info.append(row)
    np_info = np.array(info)
    columns = ['id', 'name', 'num_comments', 'vote', 'title', 'url', 'created']
    # df = pd.DataFrame(np_info, columns=columns)
    utils.upload_subs_to_s3(topics, 'NetflixBestOf')
    # print(df.head())
    # upload_to_s3(df)
    # print('return ', info)
    return {'message': 'success'}


if __name__ == '__main__':
    handler(None, None)
