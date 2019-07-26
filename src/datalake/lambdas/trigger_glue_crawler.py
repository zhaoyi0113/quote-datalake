import json
import boto3
import os
import logging

logger = logging.getLogger()
logger.setLevel(logging.DEBUG)

def handler(event, context):
    logger.info('receive event ' + json.dumps(event))
    glue = boto3.client(service_name='glue')
    crawler_name = os.environ['glue_crawler_name']
    try:
        if 'Records' in event and len(event['Records']) > 0:
            key = event['Records'][0]['s3']['object']['key']
            logger.info('upload a new file ' + key)
            crawler = glue.get_crawler(Name=crawler_name)
            if crawler['Crawler']['State'] == 'READY':
                glue.start_crawler(Name=crawler_name)
                logger.info('trigger glue crawler ' + crawler_name)
            else:
                logger.info('crawler status ' + crawler['Crawler']['State'], ' is not ready.')
        else:
            logger.info('invalid event')
    except Exception as e:
        logger.info(e)
        raise e