#!/bin/bash

# Connection health checker and reconnect script

echo "🔍 Connection Health Checker"
echo "============================"

# Check if adb is running
if ! pgrep adb > /dev/null; then
    echo "🔄 Starting ADB server..."
    adb start-server
fi

# Check current connections
echo "📱 Current ADB connections:"
adb devices

# Check if we have any wireless connections
WIRELESS_DEVICES=$(adb devices | grep ":5555" | grep "device$")

if [ -z "$WIRELESS_DEVICES" ]; then
    echo "❌ No wireless connections found"
    echo "💡 Try running: ~/scripts/quick_reconnect.sh"
    exit 1
fi

echo "✅ Found wireless connection(s):"
echo "$WIRELESS_DEVICES"

# Test connection with a simple command
echo "🧪 Testing connection stability..."
PHONE_IP=$(echo "$WIRELESS_DEVICES" | head -1 | awk '{print $1}' | cut -d':' -f1)

if adb -s "$PHONE_IP:5555" shell echo "test" > /dev/null 2>&1; then
    echo "✅ Connection is stable"
    echo "🚀 Launching scrcpy with optimal settings..."
    scrcpy --max-fps 30 --video-bit-rate 4M --stay-awake
else
    echo "❌ Connection is unstable"
    echo "🔄 Attempting to reconnect..."
    
    # Try to reconnect
    adb disconnect "$PHONE_IP:5555"
    sleep 2
    
    if adb connect "$PHONE_IP:5555" | grep -q "connected"; then
        echo "✅ Reconnected successfully"
        echo "🚀 Launching scrcpy..."
        scrcpy --max-fps 30 --video-bit-rate 4M --stay-awake
    else
        echo "❌ Reconnection failed"
        echo "💡 Please run: wireless-scrcpy with USB connected"
    fi
fi
