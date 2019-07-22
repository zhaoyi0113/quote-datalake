import praw
import numpy as np
import pandas as pd
import boto3
from datetime import datetime
from io import StringIO

LIMIT = 1000

reddit = praw.Reddit(client_id='W52YZGBme79BpA',
                     client_secret='LBrMnomaVlNUI_PXcvMqPOSQtt4',
                     user_agent='my user agent')
print('token:', reddit.auth.scopes())

def upload_to_s3(df):
    csv_buffer = StringIO()
    df.to_csv(csv_buffer)
    s3_resource = boto3.resource('s3')
    file_name = 'bestof-' + datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    s3_resource.Object('jzhao-datalake-test', 'netflix/' + file_name + '.csv').put(Body=csv_buffer.getvalue())

def handler(event, context):
    print(reddit.read_only)
    info = []
    topics = reddit.subreddit('NetflixBestOf').new(limit=LIMIT)
    for submission in topics:
        print(submission.title)
        row = np.array([submission.id, submission.name, submission.num_comments,
                        submission.score, submission.title, submission.url])
        info.append(row)
    np_info = np.array(info)
    columns = ['id', 'name', 'num_comments', 'vote', 'title', 'url']
    df = pd.DataFrame(np_info, columns=columns)
    print(df.head())
    upload_to_s3(df)
    return info


if __name__ == '__main__':
    handler(None, None)
