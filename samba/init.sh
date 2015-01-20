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

function makereadonlyfolder() {
  # set setGUID bit to make all files inherit group
  chmod +s $1
  # set sticky bit to prevent deletion by other users
  chmod +t $1
}

function auditlog {

  # setup local5 syslog facility for samba.audit.log
  # nano /etc/rsyslog.d/50-default.conf
  # add:
  # local5.*                 /var/log/samba_audit.log
  # append on line where is "-/var/log/syslog"
  # local5.none

  # yet setup logrotator
  echo '/var/log/samba_audit.log {
     weekly
     missingok
     rotate 7
     postrotate
          service rsyslog restart > /dev/null 2>&1 || true
     endscript
     compress
     notifempty
  }' | sudo tee /etc/logrotate.d/samba.audit

}

auditlog
