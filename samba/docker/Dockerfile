FROM phusion/baseimage:0.9.16

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]

# ...put your own build instructions here...
RUN apt-get update && \
    apt-get install -y git \
    samba \
    nodejs npm

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# add init script
RUN mkdir /etc/service/smbd
ADD run-samba.sh /etc/service/smbd/run

RUN mkdir /etc/service/conf-app
ADD run-conf-app.sh /etc/service/conf-app/run

ADD node-eduit-userman /app

EXPOSE 139
EXPOSE 445
