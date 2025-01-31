from flask import Flask, Response, request, redirect, make_response
from urllib.parse import urlparse

import logging
import requests
import os

app = Flask(__name__)

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

@app.route('/login')
def login():

    req_headers = request.headers
    print('req_headers:', req_headers)
    host = req_headers.get('Host', '')
    proto = req_headers.get('X-Forwarded-Proto', 'http')
    print(f'host: {host} - proto: {proto}')
    params = request.args
    username = params.get('username', '')
    password = params.get('password', '')

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
        res = requests.post(f'{proto}://{host}/internal/security/login', headers=headers, json=data)
        print(res)
        print(res.content)
        print(res.cookies.get_dict())
        cookies = res.cookies.get_dict()

        # r2 = requests.get('http://kibana:5601/app/home', cookies=res.cookies)

        resp = make_response(redirect(f'{proto}://{host}/'))
        for c in cookies:
            resp.set_cookie(c, cookies[c])

        return resp

    return open('index.html', 'r').read()


if __name__ == '__main__':
    logging.info("Starting server...")

    app.run(host='0.0.0.0', port=8123, threaded=True, debug=True)

