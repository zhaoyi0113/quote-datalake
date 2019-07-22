# -*- coding: utf-8 -*-
import scrapy
import json
import urllib.parse


class RedditJsonSpider(scrapy.Spider):
    name = 'reddit_json'
    allowed_domains = ['www.reddit.com']
    start_urls = ['https://www.reddit.com/r/movies/top.json?sort=top&limit=25']
    custom_settings={
        'DEPTH_LIMIT': 100,
        'DOMAIN_DEPTHS': {'www.reddit.com/r/movies/', 100}
    }

    def parse(self, response):
        print('start parse reddit')
        jsonresponse = json.loads(response.body_as_unicode())
        print('length:', len(jsonresponse['data']['children']))

        for item in jsonresponse['data']['children']:
            info = {
                'title': item['data']['title']
            }
            yield info
        
        after = jsonresponse['data']['after']
        if after:
            url_parts = list(urllib.parse.urlparse(response.url))
            query = dict(urllib.parse.parse_qsl(url_parts[4]))
            query.update({'after': after})
            url_parts[4] = urllib.parse.unquote(urllib.parse.urlencode(query))
            next_page = urllib.parse.urlunparse(url_parts)
            url = response.urljoin(next_page)
            print('next page, ', url)
            yield scrapy.Request(url, self.parse)
        else:
            print('no more pages')
        