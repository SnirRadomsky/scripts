#!/bin/bash

# Define colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Define the Wi-Fi network name (SSID) and password
TARGET_SSID="Snir's Redmi Note 11"
INTERFACE="en0"  # Use "Wi-Fi" if en0 doesn't work
PASSWORD="12345678"

# Function to check if we're already connected to the target network
check_current_network() {
    current_ssid=$(/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -I | awk '/ SSID:/ {print substr($0, index($0, $2))}')
    
    if [ "$current_ssid" = "$TARGET_SSID" ]; then
        return 0
    fi
    
    return 1
}

# Function to check if the target network is in range
check_network_available() {
    echo "Scanning for networks..."
    # Force a new scan to get current available networks
    available_networks=$(/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -s)
    echo "All available networks:"
    echo "$available_networks"
    echo "Looking for: $TARGET_SSID"
    
    # Escape special characters in SSID for grep
    escaped_ssid=$(echo "$TARGET_SSID" | sed 's/[\[\.*^$/]/\\&/g')
    matching_network=$(echo "$available_networks" | grep -F "$TARGET_SSID")
    echo "Matching network found:"
    echo "$matching_network"
    
    if [ -n "$matching_network" ]; then
        return 0
    fi
    return 1
}

# Function to test internet connectivity
test_connection() {
    echo -e "\nTesting internet connectivity..."
    if ping -c 5 google.com; then
        echo -e "${GREEN}Internet connection successful!${NC}"
        return 0
    else
        echo -e "${RED}No internet connection${NC}"
        return 1
    fi
}

echo "Starting WiFi connection monitor..."

while true; do
    if check_current_network; then
        echo -e "Already connected to ${YELLOW}$TARGET_SSID${NC}"
        test_connection && exit 0
    else
        echo "Not connected to target network. Checking if network is available..."
        
        if check_network_available; then
            echo -e "Network ${YELLOW}$TARGET_SSID${NC} found! Attempting to connect..."
            connect_output=$(networksetup -setairportnetwork $INTERFACE "$TARGET_SSID" "$PASSWORD" 2>&1)
            
            if [[ "$connect_output" == *"Could not find network"* ]]; then
                echo -e "${RED}Could not find network $TARGET_SSID${NC}"
            fi
            
            sleep 2
            
            if check_current_network; then
                echo -e "${GREEN}Successfully connected to $TARGET_SSID${NC}"
                test_connection && exit 0
            else
                echo -e "${RED}Failed to connect to $TARGET_SSID${NC}"
            fi
        else
            echo -e "Network ${RED}$TARGET_SSID${NC} is not in range"
        fi
    fi
    
    sleep 2
done