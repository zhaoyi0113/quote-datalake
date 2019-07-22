import praw

reddit = praw.Reddit(client_id='W52YZGBme79BpA',
                     client_secret='LBrMnomaVlNUI_PXcvMqPOSQtt4',
                     user_agent='my user agent')

def handler(event, context):
    print(reddit.read_only)

    topics = reddit.subreddit('movies').hot(limit=100)
    for submission in topics:
        print(submission.title)
    
    return topics