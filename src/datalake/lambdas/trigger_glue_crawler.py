import json
import boto3

def handler(event, context):
    print('receive event ', json.dumps(event))
    glue = boto3.client(service_name='glue')
    try:
        glue.start_crawler(Name='reddit_movie')
    except Exception as e:
        print(e)
        raise e