
if [ -z "$SERVERSECRET" ]; then echo "export SERVERSECRET"; exit 11; fi

NODEAPPDIR="/var/node"

function nvm() {
  # NVM_DIR="/usr/local/nvm"
  curl https://raw.githubusercontent.com/creationix/nvm/v0.20.0/install.sh | bash
  source ~/.bashrc
  export NVM_NODEJS_ORG_MIRROR=http://nodejs.org/dist
  nvm install v0.11
  nvm alias default v0.11
  npm set strict-ssl false
}

function addNodeInstance() {
  instanceName=$1
  $CFGFILE=/etc/init.d/$instanceName
  cp node_template.conf.pref $CFGFILE
  sudo sed "s/{{ NAME }}/$instanceName/g" -i $CFGFILE
  update-rc.d $instanceName defaults
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
}

function installUserman() {
  APPNAME="eduit-userman"
  cd $NODEAPPDIR
  git clone https://github.com/vencax/node-eduit-userman $APPNAME
  cd $APPNAME
  npm install

  echo "export SERVER_SECRET=$SERVERSECRET" >> .env
  #echo "export CORSORIGIN="192.168.1.1" >> .env

  addNodeInstance $APPNAME
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
}

function installAngularApp {
  cd $NODEAPPDIR
  git clone https://github.com/vencax/angular-eduit
  cd angular-eduit
  export API_URL='eduit-userman.skola.local'
  export DHCPD_URL='dhcpd-rest.skola.local'
  ./node_modules/.bin/lineman build
}

sudo mkdir $NODEAPPDIR && sudo chown $USER $NODEAPPDIR

nvm

installDhcpdRest
installUserman
installEduITServer
installAngularApp
