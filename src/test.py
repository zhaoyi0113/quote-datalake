from datalake.utils import utils
from datalake.lambdas import newpost_monitor as nm
import time

if __name__ == '__main__':
    print('this is test')
    while True:
        nm.handler({'topic': 'news'}, None)
        time.sleep(5)