if [ -z "$SITE_DOMAIN" ]; then echo "export SITE_DOMAIN"; exit 11; fi
if [ -z "$CITY" ]; then echo "export CITY"; exit 11; fi

TMP=/tmp/easy-rsa

mkdir $TMP
cp -R /usr/share/doc/openvpn/examples/easy-rsa/2.0/* $TMP

sed 's/KEY_COUNTRY="US"/KEY_COUNTRY="CZ"/g' -i $TMP/vars
sed 's/KEY_PROVINCE="CA"/KEY_PROVINCE="CZ"/g' -i $TMP/vars
sed "s/KEY_CITY=\"SanFrancisco\"/export KEY_CITY=\"$CITY\"/g" -i $TMP/vars
sed 's/KEY_ORG="Fort-Funston"//g' -i $TMP/vars
sed 's/KEY_EMAIL="me@myhost.mydomain"/KEY_EMAIL="admin@localhost"/g' -i $TMP/vars
sed 's/KEY_OU=changeme/KEY_OU=skola/g' -i $TMP/vars
sed 's/KEY_CN=changeme/KEY_CN=skola/g' -i $TMP/vars
sed 's/KEY_NAME=changeme/KKEY_NAME=skola/g' -i $TMP/vars

cd $TMP
ln -s openssl-1.0.0.cnf openssl.cnf
source ./vars && ./clean-all && ./build-dh && ./build-ca && \
        ./build-key-server server && ./build-key client
        
tar -czf /tmp/clientCerts.tgz keys
sudo cp keys/ca.crt keys/ca.key keys/server.crt \
        keys/server.key keys/dh1024.pem $ROOT/cert
        
cd /tmp
rm -rf $TMP
    
echo "Client keys are in /tmp/clientCerts.tgz !!!!!!!!"
