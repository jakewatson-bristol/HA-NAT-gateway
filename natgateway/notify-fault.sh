#!/bin/bash
# /etc/keepalived/fault.sh
echo "keepalived: Entered FAULT state - flushing conntrack table..." >> /var/log/keepalived.log
# Flush conntrack table
/usr/sbin/conntrackd -f >> /var/log/keepalived.log 2>&1

# Remove SNAT rules for both networks
iptables -t nat -D POSTROUTING -s 172.24.0.0/16 -j SNAT --to-source 172.24.0.100
iptables -t nat -D POSTROUTING -s 172.23.0.0/16 -j SNAT --to-source 172.23.0.100


echo "keepalived: Entered FAULT state - flushed conntrack table" >> /var/log/keepalived.log