# NEED TO KNOWs

## Setting up elastic stack

1. compose up (`-d` optional to daemonize)
```
docker-compose up
```

2. after kibana & elasticsearch is up, go to <host-ip-address>:<forwarded-port-of-kibana>

3. Click `Where to find this` on Kibana to get a setup token

4. run command to get the setup token. Note, change `elasticsearch` to your elasticsearch service name in `docker-compose.yml`
```
docker-compose exec elasticsearch bin/elasticsearch-create-enrollment-token --scope kibana
```

5. run command to get the verification code. Note, change `kibana` to your kibana service name in `docker-compose.yml`
```
docker-compose exec kibana bin/kibana-verification-code
```

6. Enter username `elastic` and password is `ELASTIC_PASSWORD` environment variable

7. Done!

Notes:

- Elasticsearch needs environment variable `ES_JAVA_OPTS=-Xms2g -Xmx2g` set to `2g` each

- Default kibana superuser is `elastic`. Set the password in `ELASTIC_PASSWORD` environment variable in `elasticsearch docker`

