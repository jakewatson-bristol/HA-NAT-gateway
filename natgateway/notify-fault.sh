#!/bin/bash
# /etc/keepalived/fault.sh

# Flush conntrack table
/usr/sbin/conntrackd -f

logger "conntrackd: Entered FAULT state - flushed conntrack table"