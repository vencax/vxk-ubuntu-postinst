if [ -z "$SERVER_ADDRESS" ]; then echo "export SERVER_ADDRESS"; exit 11; fi
if [ -z "$LTSPROOT" ]; then echo "export LTSPROOT"; exit 11; fi

mkdir $LTSPROOT/opt
mkdir $LTSPROOT/conf
mkdir $LTSPROOT/logs
mkdir $LTSPROOT/run
mkdir $LTSPROOT/aptcache

CFG=$LTSPROOT/conf/lts.conf
cp lts.conf.pref $CFG
sed "s/{{ SERVER_ADDRESS }}/$SERVER_ADDRESS/g" -i $CFG

docker build -t vencax/node-eduit .
