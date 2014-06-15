if [ -z "$SERVER_NAME" ]; then echo "export SERVER_NAME"; exit 11; fi
if [ -z "$USERDB_USERNAME" ]; then echo "export USERDB_USERNAME"; exit 11; fi
if [ -z "$USERDB_PWD" ]; then echo "export USERDB_PWD"; exit 11; fi
if [ -z "$USERDB_NAME" ]; then echo "export USERDB_NAME"; exit 11; fi

sudo aptitude install -y libnss-mysql-bg mysql-client

NSSWITCH_CONF_FILE=/etc/nsswitch.conf
sudo sed 's/compat/compat mysql/g' -i $NSSWITCH_CONF_FILE

CFGFILE=/etc/libnss-mysql.cfg
sudo cp libnss-mysql.conf.pref $CFGFILE
sudo sed "s/{{ SERVER_NAME }}/$SERVER_NAME/g" -i $CFGFILE
sudo sed "s/{{ DB_NAME }}/$USERDB_NAME/g" -i $CFGFILE
sudo sed "s/{{ DB_USERNAME }}/$USERDB_USERNAME/g" -i $CFGFILE
sudo sed "s/{{ DB_PWD }}/$USERDB_PWD/g" -i $CFGFILE

CFGFILE=/etc/libnss-mysql-root.cfg
echo "username  $USERDB_USERNAME" | sudo tee $CFGFILE
echo "password  $USERDB_PWD" | sudo tee -a $CFGFILE
sudo chmod 600 $CFGFILE