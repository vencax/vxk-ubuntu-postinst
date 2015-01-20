
if [ -z "$SERVER_ADDRESS" ]; then echo "export SERVER_ADDRESS"; exit 11; fi

TFTBASE=/var/lib/tftpboot/ltsp/i386

function install(destination) {
  LINK="http://downloads.sourceforge.net/project/\
clonezilla/clonezilla_live_alternative/20140915-trusty/\
clonezilla-live-20140915-trusty-i386.iso"
  ISO="clonzilla.iso"
  wget $LINK -o $destination/$ISO
  mount -o loop $destination/$ISO /mnt
  cp /mnt/live/vmlinuz $TFTBASE/czilla.vmlinuz
  cp /mnt/live/initrd.img $TFTBASE/czilla.initrd.img
  cp /mnt/live/filesystem.squashfs $TFTBASE/czillafilesystem.squashfs
  umount /mnt
  rm $destination/$ISO

  MENUFILE="$TFTBASE/pxelinux.cfg/clonezilla"
  cp bootmenu.conf.pref $MENUFILE
  sudo sed "s/{{ SERVER_ADDRESS }}/$SERVER_ADDRESS/g" -i $MENUFILE

}

install('/tmp')
