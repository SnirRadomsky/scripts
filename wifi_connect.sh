#!/bin/bash

# Define the Wi-Fi network name (SSID) and password
TARGET_SSID="Snir's Redmi Note 11"
INTERFACE="en0"  # Use "Wi-Fi" if en0 doesn't work
PASSWORD="12345678"

while true; do
    # Get the list of available networks
    AVAILABLE_NETWORKS=$(networksetup -listpreferredwirelessnetworks "$INTERFACE")

    # Check if the target network is in the list
    if echo "$AVAILABLE_NETWORKS" | grep -q "$TARGET_SSID"; then
        echo "Network $TARGET_SSID found. Attempting to connect..."
        
        # Try to connect to the network
        networksetup -setairportnetwork "$INTERFACE" "$TARGET_SSID" "$PASSWORD"

        # If connected, exit the loop
        if networksetup -getairportnetwork "$INTERFACE" | grep -q "$TARGET_SSID"; then
            echo "Successfully connected to $TARGET_SSID."
            break
        else
            echo "Failed to connect. Retrying..."
        fi
    else
        echo "$TARGET_SSID not found. Scanning again..."
    fi

    # Wait 10 seconds before trying again
    sleep 10
done
