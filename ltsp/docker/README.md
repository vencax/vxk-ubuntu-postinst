

## Updating LTSP images

```
LTSPDATA=/BIG/dockerLTSP
docker run -t -i --privileged=true \
  -v $LTSPDATA/opt:/opt/ltsp \
  -v $LTSPDATA/conf:/etc/ltsp \
  -v $LTSPDATA/aptcache/:/var/cache/apt/ \
  vencax/ltsp /bin/bash
```

## RUnning

```
LTSPDATA=/BIG/dockerLTSP
docker run \
  -v $LTSPDATA/opt:/opt/ltsp \
  -v $LTSPDATA/conf:/etc/ltsp \
  -v $LTSPDATA/aptcache/:/var/cache/apt/ \
  -v /etc/nbd-server/conf.d/:/etc/nbd-server/conf.d/ \
  -p 10809:10809 \
  -p 69:69/udp \
  vencax/ltsp /sbin/my_init
```
