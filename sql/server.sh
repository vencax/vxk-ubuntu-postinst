if [ -z "$USERDB_USERNAME" ]; then echo "export USERDB_USERNAME"; exit 11; fi
if [ -z "$USERDB_PWD" ]; then echo "export USERDB_PWD"; exit 11; fi
if [ -z "$USERDB_NAME" ]; then echo "export USERDB_NAME"; exit 11; fi

sudo aptitude install -y mysql-server
# libmysqlclient-dev

CFGFILE=/etc/mysql/my.cnf
sudo sed "s/127.0.0.1/0.0.0.0/g" -i $CFGFILE
sudo sed "s/[mysqld]/[mysqld]\ncollation-server = utf8_unicode_ci\ninit-connect='SET NAMES utf8'\ncharacter-set-server = utf8/g"  -i $CFGFILE
sudo service mysql restart

sudo mysqladmin -p create $USERDB_NAME
T=/tmp/uuuuu
cat > $T <<EOF
CREATE USER $USERDB_USERNAME IDENTIFIED BY '$USERDB_PWD';
GRANT ALL ON $USERDB_NAME.* TO '$USERDB_USERNAME'@'%' IDENTIFIED BY '$USERDB_PWD';
GRANT ALL ON $USERDB_NAME.* TO '$USERDB_USERNAME'@'localhost' IDENTIFIED BY '$USERDB_PWD';
FLUSH PRIVILEGES;
EOF
sudo mysql -u root -p < $T
rm $T