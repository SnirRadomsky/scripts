#!/bin/bash

# Ultra-conservative wireless scrcpy for stability

echo "📡 Conservative Wireless scrcpy"
echo "==============================="

IP="192.168.1.109"

echo "🧹 Cleaning up connections..."
adb kill-server
sleep 2
adb start-server

echo "🔌 Connecting to $IP:5555..."
if adb connect $IP:5555 | grep -q "connected"; then
    echo "✅ Connected"
    
    # Wait longer for connection to stabilize
    echo "⏳ Waiting for connection to stabilize..."
    sleep 5
    
    # Test connection
    if adb -s "$IP:5555" shell echo "test" >/dev/null 2>&1; then
        echo "✅ Connection stable"
        echo "🚀 Launching with ultra-conservative settings..."
        
        # Very conservative settings for stability
        scrcpy -s "$IP:5555" \
               --max-fps 15 \
               --video-bit-rate 1M \
               --stay-awake \
               --window-title "Android (Conservative)" \
               --no-audio \
               --max-size 1024
    else
        echo "❌ Connection unstable"
        echo "💡 Try USB mode: ~/scripts/usb_scrcpy.sh"
    fi
else
    echo "❌ Connection failed"
    echo "💡 Please check WiFi and try USB mode"
fi