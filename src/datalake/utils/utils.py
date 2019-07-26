import praw
import numpy as np
import pandas as pd
import os
from io import StringIO
import boto3
from datetime import datetime
import time
import json

S3_BUCKET = os.environ['s3_bucket']
ATHENA_RESULT_BUCKET = os.environ['athena_bucket']
ATHENA_DB_NAME = 'video'

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
    s3_resource.Object(S3_BUCKET, topic + '/' +
                       file_name).put(Body=json.dumps(json_data))
    print('upload file ' + file_name + ' to s3 bucket ' + S3_BUCKET + '/' + topic)


def query_submission_id(names):
    try:
        client = boto3.client('athena', region_name='ap-southeast-2')
        condition = '('
        for name in names:
            if len(condition) > 1:
                condition = condition + ','
            condition = condition + '\'' + name + '\''
        condition += ')'
        print('condition=', condition)
        execution = client.start_query_execution(
            QueryString='select name from "target_reddit_movie" where name in ' + condition + ' group by name',
            QueryExecutionContext={
                'Database': ATHENA_DB_NAME
            },
            ResultConfiguration={
                'OutputLocation': 's3://' + ATHENA_RESULT_BUCKET + '/athena-results'
            }
        )
        execution_id = execution['QueryExecutionId']
        while True:
            response = client.get_query_execution(QueryExecutionId=execution_id)
            print('query response ', response)
            if 'QueryExecution' in response and \
                    'Status' in response['QueryExecution'] and \
                    'State' in response['QueryExecution']['Status']:
                state = response['QueryExecution']['Status']['State']
                if state == 'FAILED':
                    return []
                elif state == 'SUCCEEDED':
                    df = load_csv_from_s3(ATHENA_RESULT_BUCKET, 'athena-results/' +
                                        response['QueryExecution']['QueryExecutionId']+'.csv')
                    return df['name'].values.tolist()
            time.sleep(5)
    except Exception as e:
        print(e)
    return []


def load_csv_from_s3(bucket, key):
    client = boto3.client('s3')
    obj = client.get_object(Bucket=bucket, Key=key)
    dataframe = pd.read_csv(obj['Body'])
    return dataframe
