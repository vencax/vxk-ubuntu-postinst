if [ -z "$SITE_DOMAIN" ]; then echo "export SITE_DOMAIN"; exit 11; fi
if [ -z "$SERVER_ADDRESS" ]; then echo "export SERVER_ADDRESS"; exit 11; fi
if [ -z "$SERVER_NAME" ]; then echo "export SERVER_NAME"; exit 11; fi
if [ -z "$SITE_GATEWAY" ]; then echo "export SITE_GATEWAY"; exit 11; fi
if [ -z "$NETWORKPART" ]; then echo "export NETWORKPART"; exit 11; fi
if [ -z "$REVNETWORK" ]; then echo "export REVNETWORK"; exit 11; fi

ROOT=/etc/bind
ZONE_CNF=$ROOT/$SITE_DOMAIN.conf

sudo aptitude install -y bind9

# prepare zone config file
sudo cp zone.conf.pref $ZONE_CNF
sudo sed "s/{{ REVNETWORK }}/$REVNETWORK/g" -i $ZONE_CNF
sudo sed "s/{{ DOMAIN }}/$SITE_DOMAIN/g" -i $ZONE_CNF

# include it into master config
echo "include \"$ZONE_CNF\";" | sudo tee -a /etc/bind/named.conf.local

# prepare zone hosts file
ZONE_HOSTS=/var/cache/bind/$SITE_DOMAIN.hosts
sudo cp zone.hosts.pref $ZONE_HOSTS
sudo sed "s/{{ DOMAIN }}/$SITE_DOMAIN/g" -i $ZONE_HOSTS
sudo sed "s/{{ SERVER_ADDRESS }}/$SERVER_ADDRESS/g" -i $ZONE_HOSTS
sudo sed "s/{{ SERVER_NAME }}/$SERVER_NAME/g" -i $ZONE_HOSTS
sudo chown bind:bind $ZONE_HOSTS

# prepare reverse zone hosts file
REV_ZONE_HOSTS=/var/cache/bind/$REVNETWORK.in-addr.arpa.hosts
sudo cp revzone.hosts.pref $REV_ZONE_HOSTS
sudo sed "s/{{ REVNETWORK }}/$REVNETWORK/g" -i $REV_ZONE_HOSTS
sudo sed "s/{{ DOMAIN }}/$SITE_DOMAIN/g" -i $REV_ZONE_HOSTS
sudo sed "s/{{ SERVER_NAME }}/$SERVER_NAME/g" -i $REV_ZONE_HOSTS
sudo chown bind:bind $REV_ZONE_HOSTS

# prepare logging files
sudo mkdir /var/log/named
sudo chown bind /var/log/named
echo '
logging{
    channel simple_log {
        file "/var/log/named/named.log" versions 3 size 50m;
        severity dynamic;
        print-time yes;
        print-severity yes;
        print-category yes;
    };
    category default { simple_log; };
    category notify { null; };
    category lame-servers { null; };
};' | sudo tee -a /etc/bind/named.conf.options

# sudo sed "s/dnssec-validation auto/dnssec-validation no/g" -i /etc/bind/named.conf.options
