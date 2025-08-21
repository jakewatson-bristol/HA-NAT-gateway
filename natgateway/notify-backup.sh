#!/bin/bash
# /etc/keepalived/backup.sh

echo "keepalived: transitioned to BACKUP - sending state to other nodes..." >> /var/log/keepalived.log
/usr/sbin/conntrackd -B >> /var/log/keepalived.log 2>&1

echo "keepalived: Transitioned to BACKUP - flushing conntrack table..." >> /var/log/keepalived.log
# Flush kernel conntrack table to avoid conflicts
/usr/sbin/conntrackd -f >> /var/log/keepalived.log 2>&1

echo "keepalived: Requesting resync from MASTER..." >> /var/log/keepalived.log
# Optional: Request resync to get current state
/usr/sbin/conntrackd -R >> /var/log/keepalived.log 2>&1

# Remove SNAT rules for both networks
iptables -t nat -D POSTROUTING -s 172.24.0.0/16 -j SNAT --to-source 172.24.0.100
iptables -t nat -D POSTROUTING -s 172.23.0.0/16 -j SNAT --to-source 172.23.0.100

# Log the transition
echo "keepalived: Transitioned to BACKUP - flushed conntrack table" >> /var/log/keepalived.log