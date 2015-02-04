
if [ -z "$SERVERSECRET" ]; then echo "export SERVERSECRET"; exit 11; fi

NODEAPPDIR="/var/node"

function nvm() {
  NVM_DIR="/usr/local/nvm"
  curl https://raw.githubusercontent.com/creationix/nvm/v0.20.0/install.sh | bash
  source ~/.bashrc
  nvm install v0.11
  nvm alias default v0.11
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
  echo "export PORT=7801" >> .env
  echo "export RELOAD_DHCPD='service isc-dhcp-server reload'" >> .env
  echo "export SERVER_SECRET=$SERVERSECRET" >> .env
  #echo "export CORSORIGIN="192.168.1.1" >> .env

  addNodeInstance $APPNAME
}

sudo mkdir $NODEAPPDIR && sudo chown $USER $NODEAPPDIR

nvm

installDhcpdRest
