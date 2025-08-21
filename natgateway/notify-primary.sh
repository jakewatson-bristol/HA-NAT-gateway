#!/bin/bash
# /etc/keepalived/master.sh

echo "keepalived: Transitioned to MASTER - committing external cache..." >> /var/log/keepalived.log

# get current conntrackd state from other nodes
/usr/sbin/conntrackd -n >> /var/log/keepalived.log 2>&1

# Commit external cache to kernel conntrack table
/usr/sbin/conntrackd -c >> /var/log/keepalived.log 2>&1

# Add SNAT rules for both networks
iptables -t nat -A POSTROUTING -s 172.24.0.0/16 -j SNAT --to-source 172.24.0.100
iptables -t nat -A POSTROUTING -s 172.23.0.0/16 -j SNAT --to-source 172.23.0.100

# Log the transition
echo "keepalived: Transitioned to MASTER - committed external cache" >> /var/log/keepalived.log