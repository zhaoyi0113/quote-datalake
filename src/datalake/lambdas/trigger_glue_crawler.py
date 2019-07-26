import json
import boto3
import os


def handler(event, context):
    print('receive event ', json.dumps(event))
    glue = boto3.client(service_name='glue')
    crawler_name = os.environ['glue_crawler_name']
    try:
        if 'Records' in event and len(event['Records']) > 0:
            key = event['Records'][0]['s3']['object']['key']
            print('upload a new file ', key)
            glue.start_crawler(Name=crawler_name)
            print('trigger glue crawler ', crawler_name)
        else:
            print('invalid event')
    except Exception as e:
        print(e)
        raise e