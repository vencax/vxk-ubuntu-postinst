if [ -z "$USERDB_USERNAME" ]; then echo "export USERDB_USERNAME"; exit 11; fi
if [ -z "$USERDB_PWD" ]; then echo "export USERDB_PWD"; exit 11; fi
if [ -z "$COMMANDER" ]; then echo "export COMMANDER"; exit 11; fi
if [ -z "$SITE_DOMAIN" ]; then echo "export SITE_DOMAIN"; exit 11; fi

ROOT=/var/wsgi
PROJROOT=$ROOT/s21
PROJURL=https://github.com/vencax/py-s21-admin
UWSGIROOT=/etc/uwsgi
U=www-data

sudo aptitude install -y uwsgi uwsgi-plugin-python \ 
	python-setuptools \
	build-essential python-dev libmysqlclient-dev
sudo easy_install pip

mkdir $ROOT
chown $U:$U $ROOT

sudo -u $U "git clone $PROJURL $PROJROOT"
cd $PROJROOT

pip install -r requirements.txt

# commander user creation
sudo useradd $COMMANDER
echo "$COMMANDER ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/commander
chmod 0440 /etc/sudoers.d/commander
COMMANDERSECRET=`openssl rand -base64 32`
sudo passwd $COMMANDER <<EOF
$COMMANDERSECRET
$COMMANDERSECRET
EOF

CFGFILE=$UWSGIROOT/apps-available/s21.ini
sudo cp conf.ini.pref $CFGFILE
sudo ln -s $UWSGIROOT/apps-available/s21.ini $UWSGIROOT/apps-enabled/s21.ini

DJSECRET=`openssl rand -base64 32`
sudo sed "s/{{ DJANGO_SECRET }}/$DJSECRET/g" -i $CFGFILE
sudo sed "s/{{ DBUSER }}/$USERDB_USERNAME/g" -i $CFGFILE
sudo sed "s/{{ DBPASS }}/$USERDB_PWD/g" -i $CFGFILE
sudo sed "s/{{ COMMAND_TARGET_USER }}/$COMMANDER/g" -i $CFGFILE
sudo sed "s/{{ COMMAND_TARGET_PASSWD }}/$COMMANDERSECRET/g" -i $CFGFILE

cd $PROJROOT
sudo -u $U cat <<EOL
export DJANGO_SECRET=$DJSECRET
export DBUSER=$USERDB_USERNAME
export DBPASS=$USERDB_PWD
EOL > .env

sudo -u $U source .env && python manage.py collectstatics -l -y
sudo -u $U source .env && python manage.py syncdb

# install nginx
sudo aptitude install -y nginx

CFGFILE=/etc/nginx/sites-available/s21.conf
sudo cp nginx.conf.pref $CFGFILE
sudo sed "s/{{ DOMAIN }}/$SITE_DOMAIN/g" -i $CFGFILE
cd /etc/nginx/sites-enabled
sudo ln -s ../sites-available/s21.conf .
sudo service nginx restart
