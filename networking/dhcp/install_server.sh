if [ -z "$SITE_DOMAIN" ]; then echo "export SITE_DOMAIN"; exit 11; fi
if [ -z "$SERVER_ADDRESS" ]; then echo "export SERVER_ADDRESS"; exit 11; fi
if [ -z "$SITE_GATEWAY" ]; then echo "export SITE_GATEWAY"; exit 11; fi
if [ -z "$NETPART" ]; then echo "export NETPART"; exit 11; fi
if [ -z "$REVNETWORK" ]; then echo "export REVNETWORK"; exit 11; fi

ROOT=/etc/dhcp
sudo aptitude install -y dhcp3-server

CNF=$ROOT/dhcpd.conf
sudo cp dhcpd.conf.pref $ROOT/dhcpd.conf

sudo sed "s/{{ DOMAIN }}/$SITE_DOMAIN/g" -i $CNF
sudo sed "s/{{ SERVERIP }}/$SERVER_ADDRESS/g" -i $CNF
sudo sed "s/{{ ROUTER }}/$SITE_GATEWAY/g" -i $CNF
sudo sed "s/{{ NETWORKPART }}/$NETPART/g" -i $CNF
sudo sed "s/{{ REVNETWORK }}/$REVNETWORK/g" -i $CNF

SECRET=`sudo cat /etc/bind/rndc.key | grep secret | cut -d ' ' -f 2 | sed 's/\//\\\//g'`
sudo sed "s/{{ SECRET }}/$SECRET/g" -i $CNF

cat <<EOF | sudo tee /etc/rsyslog.d/25-dhcpd.conf
dhcpd0.*                /var/log/dhcpd.log
dhcpd0.none             -/var/log/syslog
EOF

sudo service rsyslog restart
sudo service isc-dhcp-server restart
