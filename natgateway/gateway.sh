#!/bin/bash
# Gateway script for NAT instances
# This script sets up the NAT gateway with keepalived and conntrackd
while true; do
    TRY_COUNT=0
    while ! pgrep sshd >/dev/null; do
        # wait for the SSH daemon to start
        if pgrep sshd >/dev/null; then
            echo "SSH daemon is running"
            break
        else
            echo "Waiting for SSH daemon to start..."
            sleep 1
            # Start the SSH daemon if it's not running
            /usr/sbin/sshd
            TRY_COUNT=$((TRY_COUNT + 1))
            echo "Attempt $TRY_COUNT to start SSH daemon"
        fi
        if [ $TRY_COUNT -ge 5 ]; then
            echo "SSH daemon failed to start after 5 attempts, exiting..."
            echo "skipping SSH setup for $HOSTNAME"
            break
        fi
    done
    # Use $HOSTNAME to select config files directly
    TRY_COUNT=0
    while ! pgrep keepalived >/dev/null; do
        echo "Waiting for keepalived to start..."
        sleep 1
        if ! pgrep keepalived >/dev/null; then
            echo "keepalived is not running, trying to start it again..."
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

    TRY_COUNT=0
    while ! pgrep conntrackd >/dev/null; do
        echo "Waiting for conntrackd to start..."
        sleep 1
        if ! pgrep conntrackd >/dev/null; then
            echo "conntrackd is not running, trying to start it again..."
            conntrackd -C /etc/conntrackd/conntrackd.$HOSTNAME.conf -d
            TRY_COUNT=$((TRY_COUNT + 1))
            echo "Attempt $TRY_COUNT to start conntrackd"
            if [ $TRY_COUNT -ge 5 ]; then
                echo "Failed to start conntrackd after 5 attempts, exiting..."
                echo "skipping conntrackd setup for $HOSTNAME"
                break
            fi
        fi
    done
done
# Keep the script running indefinitely
# This is necessary to keep the container alive