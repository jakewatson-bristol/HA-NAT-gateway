#!/bin/bash
# Gateway script for NAT instances
# This script sets up the NAT gateway with keepalived and conntrackd

# remove the lock file if it exists
if [ -f /var/lock/conntrackd.lock ]; then
    rm /var/lock/conntrackd.lock
fi

while true; do
    # Start conntrackd
    # Detect which nat gateway instance this is
    if [ "$HOSTNAME" == "nat1" ]; then
        NET2_ETH=$(ip -o -4 addr show | awk '/172\.24\.0\.10/ {print $2}')
    else
        NET2_ETH=$(ip -o -4 addr show | awk '/172\.24\.0\.11/ {print $2}')
    fi
    TRY_COUNT=0
    while ! pgrep conntrackd >/dev/null; do
        echo "conntrackd is not running, trying to start it..."
        sleep 1
        if ! pgrep conntrackd >/dev/null; then
            # Substitute the interface in the configuration file
            sed "s/__NET2_ETH__/$NET2_ETH/g" /etc/conntrackd/conntrackd.$HOSTNAME.conf > /etc/conntrackd/conntrackd.conf
            conntrackd -C /etc/conntrackd/conntrackd.conf -d
            TRY_COUNT=$((TRY_COUNT + 1))
            echo "Attempt $TRY_COUNT to start conntrackd"
            if [ $TRY_COUNT -ge 5 ]; then
                echo "Failed to start conntrackd after 5 attempts, exiting..."
                echo "skipping conntrackd setup for $HOSTNAME"
                break
            fi
        fi
    done
    # Start keepalived
    TRY_COUNT=0
    while ! pgrep keepalived >/dev/null; do
        echo "keepalived is not running, trying to start it..."
        sleep 1
        if ! pgrep keepalived >/dev/null; then
            keepalived -D -f /etc/keepalived/keepalived.$HOSTNAME.conf
            TRY_COUNT=$((TRY_COUNT + 1))
            echo "Attempt $TRY_COUNT to start keepalived"
            if [ $TRY_COUNT -ge 5 ]; then
                echo "Failed to start keepalived after 5 attempts, exiting..."
                echo "skipping keepalived setup for $HOSTNAME"
                break
            fi
        fi
    done
done
# Keep the script running indefinitely
# This is necessary to keep the container alive