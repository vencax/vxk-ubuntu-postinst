if [ $# -ne 4 ]
then
  echo "Usage: `basename $0` SERVER_NAME SERVER_ADDRESS SITE_DOMAIN SITE_GATEWAY"
  exit -1
fi

SERVER_NAME=$1
SERVER_ADDRESS=$2
SITE_DOMAIN=$3
SITE_GATEWAY=$4

echo $SERVER_NAME > /etc/hostname

sudo aptitude install -y bridge-utils

INFCSFNAME=/etc/network/interfaces
sudo cp interfaces.pref $INFCSFNAME
sed "s/{{ GATEWAY }}/$SITE_GATEWAY" -i $INFCSFNAME
sed "s/{{ SERVERIP }}/$SERVER_ADDRESS" -i $INFCSFNAME
sed "s/{{ SITE_DOMAIN }}/$SITE_DOMAIN" -i $INFCSFNAME

# remove waiting for network
sed 's/sleep 40/#sleep 40' -i /etc/init/failsafe.conf
sed 's/sleep 59/#sleep 59' -i /etc/init/failsafe.conf

echo "nameserver $SERVER_ADDRESS" >> /etc/resolvconf/resolv.conf.d/base
echo "domain $SITE_DOMAIN" >> /etc/resolvconf/resolv.conf.d/base
