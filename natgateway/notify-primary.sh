#!/bin/bash
# /etc/keepalived/master.sh

echo "keepalived: Transitioned to MASTER - committing external cache..." >> /var/log/keepalived.log

# Commit external cache to kernel conntrack table
/usr/sbin/conntrackd -c >> /var/log/keepalived.log 2>&1

echo "keepalived: Requesting bulk sync from other nodes..." >> /var/log/keepalived.log
# Request bulk sync from other nodes (optional but recommended)
/usr/sbin/conntrackd -R >> /var/log/keepalived.log 2>&1

# Add SNAT rules for both networks
iptables -t nat -A POSTROUTING -s 172.24.0.0/16 -j SNAT --to-source 172.24.0.100
iptables -t nat -A POSTROUTING -s 172.23.0.0/16 -j SNAT --to-source 172.23.0.100

# Log the transition
echo "keepalived: Transitioned to MASTER - committed external cache" >> /var/log/keepalived.log