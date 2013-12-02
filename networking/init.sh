if [ -z "$SERVER_NAME" ]; then echo "export SERVER_NAME"; exit 11; fi
if [ -z "$SERVER_ADDRESS" ]; then echo "export SERVER_ADDRESS"; exit 11; fi
if [ -z "$SITE_DOMAIN" ]; then echo "export SITE_DOMAIN"; exit 11; fi
if [ -z "$SITE_GATEWAY" ]; then echo "export SITE_GATEWAY"; exit 11; fi

echo $SERVER_NAME | sudo tee /etc/hostname

sudo aptitude install -y bridge-utils

INFCSFNAME=/etc/network/interfaces
sudo cp interfaces.pref $INFCSFNAME
sudo sed "s/{{ GATEWAY }}/$SITE_GATEWAY/g" -i $INFCSFNAME
sudo sed "s/{{ SERVERIP }}/$SERVER_ADDRESS/g" -i $INFCSFNAME
sudo sed "s/{{ SITE_DOMAIN }}/$SITE_DOMAIN/g" -i $INFCSFNAME

# remove waiting for network
sudo sed 's/sleep 40/#sleep 40/g' -i /etc/init/failsafe.conf
sudo sed 's/sleep 59/#sleep 59/g' -i /etc/init/failsafe.conf

# setup DNS resolver
echo "nameserver $SERVER_ADDRESS" | sudo tee -a /etc/resolvconf/resolv.conf.d/base
echo "domain $SITE_DOMAIN" | sudo tee -a /etc/resolvconf/resolv.conf.d/base
