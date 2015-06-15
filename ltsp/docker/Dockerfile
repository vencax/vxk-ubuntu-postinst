FROM phusion/baseimage:0.9.16

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]

# ...put your own build instructions here...
RUN apt-get update && \
    apt-get install -y ltsp-server \
    syslinux

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

#RUN ltsp-build-client --arch="amd64" --fat-client
#RUN ltsp-config lts.conf

# add TFTP init script
RUN mkdir /etc/service/tftp
ADD run-tftp-server.sh /etc/service/tftp/run

RUN mkdir /etc/service/nbd
ADD run-nbd-server.sh /etc/service/nbd/run

EXPOSE 69/udp
EXPOSE 10809/tcp
