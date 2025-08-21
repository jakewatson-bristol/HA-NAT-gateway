FROM ubuntu:latest

RUN apt-get update && \
    apt-get install -y openssh-server openssh-client conntrackd keepalived iputils-ping iproute2 tcpdump iptables && \
    mkdir /var/run/sshd

COPY keepalived.nat1.conf /etc/keepalived/keepalived.nat1.conf
COPY keepalived.nat2.conf /etc/keepalived/keepalived.nat2.conf
COPY notify-primary.sh /etc/keepalived/notify-primary.sh
COPY notify-backup.sh /etc/keepalived/notify-backup.sh
COPY notify-fault.sh /etc/keepalived/notify-fault.sh

COPY conntrackd.nat1.conf /etc/conntrackd/conntrackd.nat1.conf
COPY conntrackd.nat2.conf /etc/conntrackd/conntrackd.nat2.conf

COPY gateway.sh /usr/local/bin/gateway.sh
RUN chmod +x /usr/local/bin/gateway.sh
RUN chmod +x /etc/keepalived/notify-primary.sh
RUN chmod +x /etc/keepalived/notify-backup.sh
RUN chmod +x /etc/keepalived/notify-fault.sh

RUN useradd test

RUN sysctl -w net.ipv4.ip_forward=1

CMD ["/usr/local/bin/gateway.sh"]