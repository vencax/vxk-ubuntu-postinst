sudo aptitude install -y postfix
sudo service postfix stop

CFG=/etc/postfix/main.cf
sudo sed "s/inet_interfaces = all/inet_interfaces = localhost/g" -i $CFG
sudo service postfix start 
