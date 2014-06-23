if [ -z "$SERVER_ADDRESS" ]; then echo "export SERVER_ADDRESS"; exit 11; fi
if [ -z "$OVPN_RANGE_BEGIN" ]; then echo "export OVPN_RANGE_BEGIN"; exit 11; fi
if [ -z "$OVPN_RANGE_END" ]; then echo "export OVPN_RANGE_END"; exit 11; fi

ROOT=/etc/openvpn
sudo aptitude install -y openvpn openssl
sudo mkdir $ROOT/confs
sudo mkdir $ROOT/cert

# enable forwarding for NOW
echo 1 | sudo tee /proc/sys/net/ipv4/ip_forward
# enable forwarding persistently
sudo sed "s/#net.ipv4.ip_forward = 1/net.ipv4.ip_forward = 1/g" -i /etc/sysctl.conf

sudo cp up.sh.pref $ROOT/up.sh
sudo chmod a+x $ROOT/up.sh
sudo cp down.sh.pref $ROOT/down.sh
sudo chmod a+x $ROOT/down.sh

sudo cp bridging.conf $ROOT/confs/bridging.conf
sudo sed "s/{{ SERVER_ADDRESS }}/$SERVER_ADDRESS/g" -i $ROOT/confs/bridging.conf
sudo sed "s/{{ OVPN_RANGE_BEGIN }}/$OVPN_RANGE_BEGIN/g" -i $ROOT/confs/bridging.conf
sudo sed "s/{{ OVPN_RANGE_END }}/$OVPN_RANGE_END/g" -i $ROOT/confs/bridging.conf
HERE=`pwd`
cd $ROOT && sudo ln -s confs/bridging.conf openvpn.conf

cd $HERE
sh -x create-keys.sh
