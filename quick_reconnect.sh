#!/bin/bash

# Quick reconnect script with better error handling

echo "🔄 Quick reconnect script"
echo "========================"

# Kill any existing adb connections first
echo "🧹 Cleaning up existing connections..."
adb kill-server
sleep 1
adb start-server

# Common IP ranges in home networks
COMMON_IPS=(
    "192.168.1.109"
    "192.168.1.110"
    "192.168.1.111"
    "192.168.0.109"
    "192.168.0.110"
    "10.0.0.109"
    "10.0.0.110"
)

echo "🔍 Trying to reconnect to previous IP addresses..."

for ip in "${COMMON_IPS[@]}"; do
    echo "Trying $ip:5555..."
    
    # Try to connect
    CONNECT_RESULT=$(adb connect $ip:5555 2>&1)
    
    if echo "$CONNECT_RESULT" | grep -q "connected\|already connected"; then
        echo "✅ Connected to $ip:5555"
        
        # Wait a moment for connection to stabilize
        sleep 2
        
        # Verify connection works
        if adb devices | grep "$ip:5555" | grep -q "device$"; then
            echo "✅ Connection verified"
            echo "🚀 Launching scrcpy..."
            
            # Launch scrcpy with more robust settings
            scrcpy --max-fps 30 --video-bit-rate 4M --stay-awake
            exit 0
        else
            echo "❌ Connection failed verification"
            adb disconnect $ip:5555 2>/dev/null
        fi
    fi
done

echo "❌ Could not reconnect to any previous IP"
echo "💡 Your phone's IP might have changed. Please run:"
echo "   1. Connect USB cable"
echo "   2. Set USB to 'File Transfer' mode"
echo "   3. Run: wireless-scrcpy"
