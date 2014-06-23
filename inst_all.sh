
ROOT=`pwd`
source ./vars

cd networking
echo "# phase #################### MAIL-SERVER #######################"
sh -x mailserver.sh
echo "# DONE ..."

echo "# phase #################### DNS-SERVER #######################"
cd dns-server
sh -x init.sh
echo "# DONE ..."

echo "# phase #################### DHCP-SERVER #######################"
cd $ROOT/networking/dhcp
sh -x install_server.sh
echo "# DONE ..."

echo "# phase #################### SQL-SERVER #######################"
cd $ROOT/sql
sh -x server.sh
echo "# DONE ..."

echo "# phase #################### ADMIN-APP #######################"
cd $ROOT/admin_app
sh -x init.sh
echo "# DONE ..."
echo "Proceed???"
read

echo "# phase #################### SQL-AUTH #######################"
cd $ROOT/sql/auth
sh -x client-stuff.sh
echo "# DONE ..."

echo "# phase #################### SAMBA-SERVER #######################"
cd $ROOT/samba
sh -x init.sh
echo "# DONE ..."

echo "# phase #################### VPN-SERVER #######################"
cd $ROOT/vpn
sh -x init.sh
echo "# DONE ..."

echo "# phase #################### LTSP-SERVER #######################"
cd $ROOT/ltsp
sh -x init.sh
echo "# DONE ..."