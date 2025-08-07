#!/bin/bash
# /etc/keepalived/backup.sh

# Flush kernel conntrack table to avoid conflicts
/usr/sbin/conntrackd -f

# Optional: Request resync to get current state
/usr/sbin/conntrackd -R

# Log the transition
logger "conntrackd: Transitioned to BACKUP - flushed conntrack table"