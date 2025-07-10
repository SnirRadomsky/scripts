#!/bin/bash

# Comprehensive ADB cleanup and reconnect script

echo "🧹 ADB Complete Cleanup & Reconnect"
echo "==================================="

# Step 1: Nuclear cleanup - kill everything
echo "💥 Performing complete ADB cleanup..."
adb kill-server
sleep 2

# Step 2: Remove any stale connections
echo "🗑️  Clearing stale connections..."
adb start-server
sleep 1

# List current state
echo "📋 Current state after cleanup:"
adb devices

# Step 3: Disconnect all wireless connections (even offline ones)
echo "🔌 Disconnecting all wireless connections..."
adb devices | grep ":5555" | awk '{print $1}' | while read device; do
    if [ ! -z "$device" ]; then
        echo "Disconnecting $device..."
        adb disconnect "$device"
    fi
done

# Step 4: Kill and restart ADB again for clean slate
echo "🔄 Final ADB restart..."
adb kill-server
sleep 2
adb start-server

echo "✅ Cleanup complete!"
echo ""
echo "📋 Final device state:"
adb devices
echo ""

# Check if USB is connected
USB_DEVICE=$(adb devices | grep -v ":5555" | grep "device$")
if [ ! -z "$USB_DEVICE" ]; then
    echo "✅ USB device detected - ready for wireless setup"
    echo "🚀 Run: wireless-scrcpy"
else
    echo "❌ No USB device detected"
    echo "💡 Please:"
    echo "   1. Connect USB cable"
    echo "   2. Set to 'File Transfer' mode"
    echo "   3. Run: wireless-scrcpy"
fi