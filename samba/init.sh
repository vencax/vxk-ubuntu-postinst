if [ -z "$SERVER_NAME" ]; then echo "export SERVER_NAME"; exit 11; fi
if [ -z "$SITE_DOMAIN" ]; then echo "export SITE_DOMAIN"; exit 11; fi

sudo aptitude install -y samba

SAMBAROOT=/media/data/samba
sudo mkdir $SAMBAROOT
sudo ln -s $SAMBAROOT /samba

sudo mkdir /samba/homes
sudo mkdir -p /samba/shares

CFG=/etc/samba/smb.conf
sudo cp smb.conf.pref $CFG
sudo sed "s/{{ SERVER_NAME }}/$SERVER_NAME/g" -i $CFG
sudo sed "s/{{ SITE_DOMAIN }}/$SITE_DOMAIN/g" -i $CFG

sudo cp -r netlogon /samba/shares