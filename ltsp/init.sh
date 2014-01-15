if [ -z "$SERVER_NAME" ]; then echo "export SERVER_NAME"; exit 11; fi
if [ -z "$SERVER_ADDRESS" ]; then echo "export SERVER_ADDRESS"; exit 11; fi
if [ -z "$SITE_DOMAIN" ]; then echo "export SITE_DOMAIN"; exit 11; fi
if [ -z "$SITE_GATEWAY" ]; then echo "export SITE_GATEWAY"; exit 11; fi

sudo aptitude install -y ltsp-server syslinux

# add neccesaary stuff into dhcp conf
DHCPSTUFF='if substring( option vendor-class-identifier, 0, 9 ) = "PXEClient" {
        filename "/ltsp/i386/pxelinux.0";
} else {
        filename "/ltsp/i386/nbi.img";
}'
CNF=/etc/dhcp/dhcpd.conf
sed -e '/# {{ PXEBOOT_OPTS_HERE }}/,$d' $CNF > dhcp.conf.tmp
echo "$DHCPSTUFF" >> dhcp.conf.tmp
sed -e '1,/# {{ PXEBOOT_OPTS_HERE }}/d' $CNF >> dhcp.conf.tmp
sudo mv dhcp.conf.tmp $CNF
sudo service isc-dhcp-server restart

CFGROOT=/etc/ltsp/
sudo mkdir $CFGROOT
sudo cp ltsp-build-client.conf.pref $CFGROOT/ltsp-build-client.conf
sudo cp ltsp-chroot.conf.pref $CFGROOT/ltsp-chroot.conf

sudo ltsp-build-client --skipimage

TFTPROOT=/var/lib/tftpboot/ltsp/i386
sudo cp /usr/lib/syslinux/menu.c32 $TFTPROOT
sudo cp menu.c32.pref $TFTPROOT

echo "copy client conf file"
sudo cp lts.conf.pref $TFTPROOT/lts.conf
sudo sed "s/{{ SERVER_ADDRESS }}/$SERVER_ADDRESS/g" -i $TFTPROOT/lts.conf

echo "prepare chroot"
sudo ltsp-chroot <<EOF
mkdir -p /samba/homes
exit
EOF

echo "
ltsp-update-image
cp $TFTPROOT/menu.c32.pref $TFTPROOT/pxelinux.cfg/default
service nbd-server restart
service tftpd-hpa restart
" | sudo tee /usr/sbin/ltsp-update-image-my
sudo chmod 775 /usr/sbin/ltsp-update-image-my
