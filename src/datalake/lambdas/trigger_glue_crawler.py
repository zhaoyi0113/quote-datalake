import json
import boto3
import os
import logging

logger = logging.getLogger()
logger.setLevel(logging.DEBUG)

def trigger_crawler(crawler_name):
    glue = boto3.client(service_name='glue')
    crawler = glue.get_crawler(Name=crawler_name)
    if crawler['Crawler']['State'] == 'READY':
        glue.start_crawler(Name=crawler_name)
        logger.info('trigger glue crawler ' + crawler_name)
    else:
        logger.info('crawler status ' + str(crawler['Crawler']['State']) + ' is not ready.')

def handler(event, context):
    logger.info('receive event ' + json.dumps(event))
    try:
        if 'Records' in event and len(event['Records']) > 0:
            # This is s3 event
            crawler_name = os.environ['glue_crawler_name']
            key = event['Records'][0]['s3']['object']['key']
            logger.info('upload a new file ' + key)
            trigger_crawler(crawler_name)
        elif 'source' in event and event['source'] == 'aws.glue':
            # This is glue job event
            crawler_name = os.environ['glue_target_crawler_name']
            logger.info('get a glue job event')
            state = event['detail']['state']
            if state == 'SUCCEEDED':
                trigger_crawler(crawler_name)
        else:
            logger.info('invalid event')
    except Exception as e:
        logger.info(e)
        raise e