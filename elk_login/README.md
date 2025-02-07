# build web app
```
fvm flutter build web --base-href="/landing/" && \
for l in $(ls build/web/)
  do cp -r build/web/$l build/web/landing/
  echo $l
done
```
