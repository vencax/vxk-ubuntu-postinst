
if [ -z "$SERVERSECRET" ]; then echo "export SERVERSECRET"; exit 11; fi

NODEAPPDIR="/var/node"
ORIGDIR=$PWD

function installNvm() {
  # NVM_DIR="/usr/local/nvm"
  curl https://raw.githubusercontent.com/creationix/nvm/v0.20.0/install.sh | bash
  source ~/.bashrc
  nvm -v
  export NVM_NODEJS_ORG_MIRROR=http://nodejs.org/dist
  nvm install 0.11
  nvm alias default 0.11
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
  echo "export API_URL='eduit-userman.skola.local'" > .env
  echo "export DHCPD_URL='dhcpd-rest.skola.local'" >> .env
  source .env && ./node_modules/.bin/lineman build
}

sudo mkdir $NODEAPPDIR && sudo chown $USER $NODEAPPDIR

# installNvm
sudo aptitude install nodejs nodejs-legacy npm
npm install forever -g

installDhcpdRest
installUserman
installEduITServer
installAngularApp
