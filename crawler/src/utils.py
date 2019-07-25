import praw
import numpy as np
import pandas as pd
import os
from io import StringIO
import boto3
from datetime import datetime
import json

S3_BUCKET = 'jzhao-datalake-test'

def createReddit():
    reddit = praw.Reddit(client_id=os.environ['praw_client_id'],
                         client_secret=os.environ['praw_client_secret'],
                         user_agent='lambda')
    return reddit

def createDataframeFromSub(subs):
    topics = []
    for submission in subs:
        row = np.array([submission.id, submission.name, submission.num_comments,
                        submission.score, submission.title, submission.url, submission.created_utc])
        topics.append(row)
    np_info = np.array(topics)
    columns = ['id', 'name', 'num_comments', 'vote', 'title', 'url', 'created']
    df = pd.DataFrame(np_info, columns=columns)
    return df

def upload_to_s3(df):
    csv_buffer = StringIO()
    df.to_csv(csv_buffer)
    s3_resource = boto3.resource('s3')
    file_name = 'bestof-' + datetime.now().strftime("%Y-%m-%d %H:%M:%S")+'.csv'
    s3_resource.Object(S3_BUCKET, 'netflix/' +
                       file_name).put(Body=csv_buffer.getvalue())
    print('upload file ' + file_name + ' to s3')

def upload_subs_to_s3(subs, topic):
    json_data = []
    for sub in subs:
        sub_dict = vars(sub)
        sub_dict.pop('_reddit')
        sub_dict.pop('subreddit')
        sub_dict.pop('author')
        json_data.append(sub_dict)
    s3_resource = boto3.resource('s3')
    file_name = 'reddit-' + datetime.now().strftime("%Y-%m-%d %H:%M:%S")+'.json'
    print(json.dumps(json_data))
    s3_resource.Object(S3_BUCKET, topic + '/' + file_name).put(Body=json.dumps(json_data))
    print('upload file ' + file_name+ ' to s3')
