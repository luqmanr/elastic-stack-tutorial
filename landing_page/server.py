from flask import Flask, Response, request, redirect, make_response
from flask_cors import CORS
from urllib.parse import urlparse

import logging
import requests
import os
import json
import jsonpickle

app = Flask(__name__)
cors = CORS(app)

@app.route('/')
def root():
    req_headers = request.headers
    print('req_headers:', req_headers)
    host = req_headers.get('Host', '')
    proto = req_headers.get('X-Forwarded-Proto', 'http')
    if proto == 'http':
        host = f'{host.split(":")[0]}:5601'
    resp = make_response(redirect(f'{proto}://{host}/login'))
    return resp

@app.route('/login', methods=['GET','POST'])
def login():

    req_headers = request.headers
    print('req_headers:', req_headers)
    host = req_headers.get('Host', '')
    proto = req_headers.get('X-Forwarded-Proto', 'http')
    print(f'host: {host} - proto: {proto}')
    params = request.args
    username = params.get('username', '')
    password = params.get('password', '')

    try:
        req = request.get_json(force=True)
        print(f'request json: {req}')
        logging.info(f'request json: {req}')
        username = req.get('username', username)
        password = req.get('password', password)
    except Exception as e:
        print(f'no json body: {e}')

#    if proto == 'http':
#        host = f'{host.split(":")[0]}:5601'

    headers = {
        "Accept": "*/*",
        "Accept-Encoding": "gzip, deflate",
        "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:134.0) Gecko/20100101 Firefox/134.0",
        "kbn-xsrf": "true",
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
        res = requests.post(f'http://kibana:5601/internal/security/login', headers=headers, json=data)
        print(res)
        print(res.content)
        print(res.cookies.get_dict())
        cookies = res.cookies.get_dict()

#        if proto == 'http':
#            host = f'{host.split(":")[0]}:5601'
        resp = make_response(redirect(f'{proto}://{host}/'))
        for c in cookies:
            resp.set_cookie(c, cookies[c])

        return resp

    return open('index.html', 'r').read()

@app.route('/logout/internal', methods=['GET','POST'])
def logout():
    r = Response(jsonpickle.encode({'status': 200, 'message': 'ok'}), mimetype="application/json", status=200)
    r.set_cookie('location', '', samesite='Lax', secure=True, max_age=0)
    r.set_cookie('sid', '', samesite='Lax', secure=True, max_age=0)
    return r

@app.route('/login/v2', methods=['GET','POST'])
def loginv2():

    req_headers = request.headers
    print('req_headers:', req_headers)
    host = req_headers.get('Host', '')
    proto = req_headers.get('X-Forwarded-Proto', 'http')
    print(f'host: {host} - proto: {proto}')
    params = request.args
    username = params.get('username', '')
    password = params.get('password', '')
    origin = params.get('origin', '')

    if len(username) == 0 or len(password) == 0:
        try:
            req = request.get_json(force=True)
            print(f'request json: {req}')
            logging.info(f'request json: {req}')
            username = req.get('username', username)
            password = req.get('password', password)
            origin = req.get('origin', origin)
        except Exception as e:
            print(f'no json body: {e}')

#    if proto == 'http':
#        host = f'{host.split(":")[0]}:5601'

    headers = {
        "Accept": "*/*",
        "Accept-Encoding": "gzip, deflate",
        "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:134.0) Gecko/20100101 Firefox/134.0",
        "kbn-xsrf": "true",
    }
    data = {
        "providerType": "basic",
        "providerName": "basic",
        "currentURL": origin,
        'params': {
            'username': username,
            'password': password
        }
    }

    if len(username) == 0 or len(password) == 0:
        response = {
            'status': 401,
            'message': 'unauthorized'
        }
        return Response(jsonpickle.encode(response), mimetype="application/json", status=response['status'])

    try:
        res = requests.post(f'http://kibana:5601/internal/security/login', headers=headers, json=data)
        # res = requests.post(f'https://dashboard.weather.id/internal/security/login', headers=headers, json=data)
    except Exception as e:
        print(f'failed to login: {e}')
        response = {
            'status': 500,
            'message': 'internal server error'
        }
        return Response(jsonpickle.encode(response), mimetype="application/json", status=response['status'])

    print(res)
    print(res.status_code)
    print(res.content)
    print(res.cookies.get_dict())
    if res.status_code != 200:
        response = {
            'status': 401,
            'message': 'unauthorized'
        }
        return Response(jsonpickle.encode(response), mimetype="application/json", status=response['status'])

    # if res.status_code == 200
    cookies = res.cookies.get_dict()
    response_json = cookies.copy()
    response_json['location'] = origin

    r = Response(jsonpickle.encode(response_json), mimetype="application/json", status=200)
    # r.headers['location'] = origin
    # r.set_cookie('location', origin, samesite='Lax', secure=True)
    for c in cookies:
        # r.headers[c] = cookies[c]
        r.set_cookie(c, cookies[c], samesite='Lax', secure=True)
    print(f'response headers: {r.headers}')

    return r

if __name__ == '__main__':
    logging.info("Starting server...")

    app.run(host='0.0.0.0', port=8123, threaded=True, debug=True)

