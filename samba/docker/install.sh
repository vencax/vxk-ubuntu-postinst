if [ -z "$SERVER_NAME" ]; then echo "export SERVER_NAME"; exit 11; fi
if [ -z "$SITE_DOMAIN" ]; then echo "export SITE_DOMAIN"; exit 11; fi
if [ -z "$SAMBAROOT" ]; then echo "export SAMBAROOT"; exit 11; fi

mkdir $SAMBAROOT/homes
mkdir $SAMBAROOT/shares
mkdir $SAMBAROOT/logs
mkdir $SAMBAROOT/run

CFG=$SAMBAROOT/smb.conf
cp smb.conf.pref $CFG
sed "s/{{ SERVER_NAME }}/$SERVER_NAME/g" -i $CFG
sed "s/{{ SITE_DOMAIN }}/$SITE_DOMAIN/g" -i $CFG

cp -r netlogon $SAMBAROOT/shares

git clone https://github.com/vencax/node-eduit-userman

docker build -t vencax/node-eduit .
