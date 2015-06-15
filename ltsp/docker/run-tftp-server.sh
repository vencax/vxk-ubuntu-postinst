#!/bin/sh
exec /usr/sbin/in.tftpd --foreground --user tftp --address [::]:69 --secure /var/lib/tftpboot
