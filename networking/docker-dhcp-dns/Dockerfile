FROM phusion/baseimage:0.9.16

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]

# ...put your own build instructions here...
RUN apt-get update && \
    apt-get install -y isc-dhcp-server \
    bind9

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# add init script
RUN mkdir /etc/service/dhcpd
ADD run-dhcpd.sh /etc/service/dhcpd/run

EXPOSE 67
EXPOSE 67/udp
EXPOSE 547
EXPOSE 547/udp
EXPOSE 647
EXPOSE 647/udp
EXPOSE 847
EXPOSE 847/udp
