from flask import Flask, Response, request, redirect, make_response
from flask_cors import CORS

from urllib.parse import urlparse

import logging
import requests
import os
import json

app = Flask(__name__)
# cors = CORS(app, resources={r"/foo": {"origins": "*"}})
cors = CORS(app)

@app.route('/')
def root():
    headers = {
        "Accept": "*/*",
        "Accept-Encoding": "gzip, deflate",
        "Host": "httpbin.org",
        "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:134.0) Gecko/20100101 Firefox/134.0",
        "kbn-xsrf": "true",
        # "Authorization": "Basic ZWxhc3RpYzphc2VjdXJlcGFzc3dvcmQ=",
        "X-Amzn-Trace-Id": "Root=1-6410831d-666f197b78c8e97a3013bea9",
        "Authorization": "ApiKey c1FWMnQ1UUIzcDJjTVVmdnpoU0s6T1lYeS10VzZSTGVYMmVCd0xLUDRNQQ=="
    }
    res = requests.get('http://127.0.0.1:8601/login', headers=headers)
    print(res.content)
    return res.content

@app.route('/login', methods=['GET', 'POST'])
def login():

    req_headers = request.headers
    print('req_headers:', req_headers)
    host = req_headers.get('Host', '')
    proto = req_headers.get('X-Forwarded-Proto', 'http')
    print(f'host: {host} - proto: {proto}')

    req = request.get_json(force=True)
    print(f'request json: {req}')
    logging.info(f'request json: {req}')
    username = req.get('username', '')
    password = req.get('password', '')

    headers = {
        "Accept": "*/*",
        "Accept-Encoding": "gzip, deflate",
        "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:134.0) Gecko/20100101 Firefox/134.0",
        "kbn-xsrf": "true",
        # "Authorization": "Basic ZWxhc3RpYzphc2VjdXJlcGFzc3dvcmQ=",
        # "X-Amzn-Trace-Id": "Root=1-6410831d-666f197b78c8e97a3013bea9",
        # "Authorization": "ApiKey cXdWc3Q1UUIzcDJjTVVmdi14UUs6dzQ5amdLaEFUWU9jWEpqWXNGczdEZw=="
    }
    data = {
        "providerType":"basic",
        "providerName":"basic",
        "currentURL":f"{proto}://{host}/login?",
        'params': {
            'username': username,
            'password': password
        }
    }

    if len(username) > 0 and len(password) > 0:
        if proto == 'http':
            host = f'{host}:88'
        res = requests.post(f'https://dashboard.weather.id/internal/security/login', headers=headers, json=data)
        print(res)
        print(res.content)
        print(res.cookies.get_dict())
        cookies = res.cookies.get_dict()

        print(f'redirecting to: {proto}://{host}/')
        resp = make_response(redirect(f'https://dashboard.weather.id/'))
        for c in cookies:
            resp.set_cookie(c, cookies[c])

        return resp

    resp = Response('ok', headers={'Access-Controler-Allow-Origin': '*',
          'Access-Control-Allow-Methods': 'GET, POST, OPTIONS'})
    return resp

    # return open('index.html', 'r').read()

if __name__ == '__main__':
    logging.info("Starting server...")

    app.run(host='0.0.0.0', port=8123, threaded=True, debug=True)

