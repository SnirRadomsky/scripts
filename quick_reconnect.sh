#!/bin/bash

# Improved quick reconnect script with better cleanup

echo "🔄 Quick reconnect script"
echo "========================"

# Step 1: Check current state
echo "📋 Current ADB state:"
adb devices

# Check for offline wireless connections and clean them up
OFFLINE_WIRELESS=$(adb devices | grep ":5555" | grep "offline")
if [ ! -z "$OFFLINE_WIRELESS" ]; then
    echo "🧹 Found offline wireless connections, cleaning up..."
    
    # Disconnect offline connections
    echo "$OFFLINE_WIRELESS" | awk '{print $1}' | while read device; do
        echo "Disconnecting offline device: $device"
        adb disconnect "$device"
    done
    
    # Restart ADB for clean state
    echo "🔄 Restarting ADB..."
    adb kill-server
    sleep 2
    adb start-server
fi

# Common IP ranges in home networks (adjust these to your network)
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
    
    if echo "$CONNECT_RESULT" | grep -q "connected"; then
        echo "✅ Connected to $ip:5555"
        
        # Wait a moment for connection to stabilize
        sleep 3
        
        # Verify connection works with a test command
        if adb -s "$ip:5555" shell echo "test" > /dev/null 2>&1; then
            echo "✅ Connection verified and stable"
            echo "🚀 Launching scrcpy with optimized settings..."
            
            # Launch scrcpy with stability settings
            scrcpy --max-fps 25 --video-bit-rate 3M --stay-awake --window-title "Android Screen"
            exit 0
        else
            echo "❌ Connection unstable, trying next IP..."
            adb disconnect $ip:5555 2>/dev/null
        fi
    elif echo "$CONNECT_RESULT" | grep -q "already connected"; then
        echo "ℹ️  Already connected to $ip:5555"
        
        # Test if it actually works
        if adb -s "$ip:5555" shell echo "test" > /dev/null 2>&1; then
            echo "✅ Existing connection is working"
            echo "🚀 Launching scrcpy..."
            scrcpy --max-fps 25 --video-bit-rate 3M --stay-awake --window-title "Android Screen"
            exit 0
        else
            echo "❌ Existing connection is dead, disconnecting..."
            adb disconnect $ip:5555
        fi
    fi
done

echo "❌ Could not reconnect to any previous IP"
echo ""
echo "🔧 Troubleshooting steps:"
echo "   1. Make sure your phone is on the same WiFi network"
echo "   2. Check if phone's IP address changed"
echo "   3. Connect USB cable and run: wireless-scrcpy"
echo "   4. If still having issues, run: ~/scripts/cleanup_adb.sh"