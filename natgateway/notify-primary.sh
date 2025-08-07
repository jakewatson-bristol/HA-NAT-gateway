#!/bin/bash
# /etc/keepalived/master.sh

# Commit external cache to kernel conntrack table
/usr/sbin/conntrackd -c

# Request bulk sync from other nodes (optional but recommended)
/usr/sbin/conntrackd -R

# Log the transition
logger "conntrackd: Transitioned to MASTER - committed external cache"