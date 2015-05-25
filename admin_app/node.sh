
if [ -z "$SERVERSECRET" ]; then echo "export SERVERSECRET"; exit 11; fi

NODEAPPDIR="/var/node"
ORIGDIR=$PWD

function installNvm() {
  NVM_DIR="/usr/local/nvm"
  curl https://raw.githubusercontent.com/creationix/nvm/v0.23.3/install.sh | \
    sudo NVM_DIR=$NVM_DIR PROFILE=/etc/profile bash
  source /etc/profile
  sudo chown -R $USER NVM_DIR
  nvm -v
  export NVM_NODEJS_ORG_MIRROR=http://nodejs.org/dist
  nvm install 0.10
  nvm alias default 0.10
  npm set strict-ssl false
}

function addNodeInstance() {
  CURRDIR=$PWD
  cd $ORIGDIR
  instanceName=$1
  cp node_template.conf.pref $instanceName.conf
  sed "s/{{ NAME }}/$instanceName/g" -i $instanceName.conf
  chmod 755 $instanceName.conf
  sudo mv $instanceName.conf /etc/init.d/$instanceName
  sudo update-rc.d $instanceName defaults
  cd $CURRDIR
}

function addNginxRec() {
  instanceName=$1
  CONFFILE=/etc/nginx/sites-available/s21.conf

  echo "server {
    listen 80;
    server_name $instanceName.skola.local;
    location / {
      proxy_pass http://unix:/var/run/$instanceName.socket;
    }
  }" | sudo tee -a $CONFFILE
}

function installDhcpdRest() {
  APPNAME="dhcpd-rest"

  cd $NODEAPPDIR
  git clone https://github.com/vencax/node-dhcp-rest-conf $APPNAME
  cd $APPNAME
  npm install

  echo "export DHCPD_CONF_FILE=/etc/dhcp/dhcpd.conf" > .env
  echo "export DHCPD_LEASES_FILE=/var/lib/dhcp/dhcpd.leases" >> .env
  echo "export RELOAD_DHCPD='service isc-dhcp-server reload'" >> .env
  echo "export SERVER_SECRET=$SERVERSECRET" >> .env
  #echo "export CORSORIGIN="192.168.1.1" >> .env

  addNodeInstance $APPNAME
  addNginxRec $APPNAME

  sudo aptitude install python-pip -y
  sudo pip install git+git://github.com/vencax/py-dhcpd-manipulation
  sudo pip install git+git://github.com/vencax/LeaseInfo
  # SYS_WIDE_ENV=/etc/environment
  # echo "DHCPD_CONF_FILE=/etc/dhcp/dhcpd.conf" | sudo tee -a $SYS_WIDE_ENV
  # echo "DHCPD_LEASES_FILE=/var/lib/dhcp/dhcpd.leases" | sudo tee -a $SYS_WIDE_ENV
}

function installUserman() {
  APPNAME="eduit-userman"
  cd $NODEAPPDIR
  git clone https://github.com/vencax/node-eduit-userman $APPNAME
  cd $APPNAME
  npm install

  echo "export SERVER_SECRET=$SERVERSECRET" > .env
  echo "export DATABASE_URL='mysql://$USERDB_USERNAME:$USERDB_PWD@localhost:3306/$USERDB_NAME'" >> .env
  echo "export PWD_SALT=wiojaoijqpkp" >> .env
  #echo "export CORSORIGIN="192.168.1.1" >> .env

  addNodeInstance $APPNAME
  addNginxRec $APPNAME
}

function installEduITServer {
  APPNAME="eduit-server"
  cd $NODEAPPDIR
  git clone https://github.com/vencax/node-eduit-server $APPNAME
  cd $APPNAME
  npm install

  echo "export SERVER_SECRET=$SERVERSECRET" >> .env
  echo "export FRONTEND_APP=$NODEAPPDIR/angular-eduit" >> .env

  addNodeInstance $APPNAME
  addNginxRec $APPNAME
}

function installAngularApp {
  cd $NODEAPPDIR
  git clone https://github.com/vencax/angular-eduit
  cd angular-eduit
  echo "export API_URL='eduit-userman.skola.local'" > .env
  echo "export DHCPD_URL='dhcpd-rest.skola.local'" >> .env
  source .env && ./node_modules/.bin/lineman build
}

sudo mkdir $NODEAPPDIR && sudo chown $USER $NODEAPPDIR

# installNvm
sudo aptitude install nodejs nodejs-legacy npm
sudo npm install forever grunt-cli bower -g

installDhcpdRest
installUserman
installEduITServer
installAngularApp
