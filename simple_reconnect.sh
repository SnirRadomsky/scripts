#!/bin/bash

# Ultra-simple reconnect - tries wireless first, falls back to USB

echo "🔄 Smart Reconnect"
echo "=================="

IP="192.168.1.109"

# Clean up any stale connections first
echo "🧹 Cleaning up stale connections..."
adb disconnect $IP:5555 2>/dev/null

echo "📋 Current devices:"
adb devices

# Try wireless connection
echo "🔌 Attempting wireless connection to $IP:5555..."
adb connect $IP:5555
sleep 3

# Check if wireless worked
if adb devices | grep "$IP:5555" | grep -q "device$"; then
    echo "✅ Wireless connection successful!"
    
    # If both USB and wireless exist, disconnect USB
    if adb devices | grep -v ":5555" | grep -q "device$"; then
        echo "🔌 Disconnecting USB to avoid conflicts..."
        USB_ID=$(adb devices | grep -v ":5555" | grep "device$" | awk '{print $1}')
        adb disconnect "$USB_ID" 2>/dev/null
        sleep 1
    fi
    
    echo "🚀 Launching scrcpy wirelessly..."
    scrcpy --max-fps 25 --video-bit-rate 3M --stay-awake
elif adb devices | grep -v ":5555" | grep -q "device$"; then
    echo "⚠️  Wireless failed, but USB detected"
    echo "🔌 Using USB connection instead..."
    scrcpy --max-fps 25 --video-bit-rate 3M --stay-awake
else
    echo "❌ No working connections found"
    echo ""
    echo "💡 Please try:"
    echo "   1. Make sure phone is connected to same WiFi"
    echo "   2. Or connect USB cable and run: ~/scripts/wireless_scrcpy.sh"
    echo "   3. Or run: ~/scripts/cleanup_adb.sh for full reset"
fi