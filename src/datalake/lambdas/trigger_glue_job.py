import boto3
import logging

logger = logging.getLogger()
logger.setLevel(logging.DEBUG)

def handler(event, context):
    logger.info('receive event')
    logger.debug(event)
    try:
        glue = boto3.client(service_name='glue')
        response = glue.start_job_run(JobName='reddit_movies')
        logger.info('started a glue job')
        logger.debug(response)
    except Exception as e:
        logger.error(e)