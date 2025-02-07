# build web app
```
fvm flutter build web --base-href="/login/" && \
for l in $(ls build/web/)
  do cp -r build/web/$l build/web/login/
  echo $l
done && \
rm -r build/web/login/login
```
