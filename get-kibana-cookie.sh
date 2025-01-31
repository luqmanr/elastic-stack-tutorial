#!/bin/bash
curl -s -X POST http://localhost:5601/internal/security/login -d '{"providerType":"basic","providerName":"basic","currentURL":"http://10.22.45.42:88/login?","params":{"username":"elastic","password":"asecurepassword"}}' -H 'kbn-xsrf: true' -H 'Content-Type: application/json' -c cookie.txt
