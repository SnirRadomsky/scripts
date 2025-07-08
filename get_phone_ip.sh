#!/bin/bash

# Script to get phone IP and connect wirelessly to scrcpy

echo "Getting phone IP address..."

# First, make sure phone is connected via USB
if ! adb devices | grep -q "device$"; then
    echo "❌ No phone detected. Please connect via USB first."
    exit 1
fi

# Get the WiFi IP address
PHONE_IP=$(adb shell ip addr show wlan0 | grep "inet " | awk '{print $2}' | cut -d'/' -f1)

if [ -z "$PHONE_IP" ]; then
    echo "❌ Phone not connected to WiFi. Please connect to WiFi first."
    exit 1
fi

echo "📱 Phone IP found: $PHONE_IP"

# Set up TCP mode
echo "🔧 Setting up wireless connection..."
adb tcpip 5555

# Wait a moment for the restart
sleep 2

# Connect wirelessly
echo "📡 Connecting wirelessly..."
adb connect $PHONE_IP:5555

# Show connected devices
echo "📋 Connected devices:"
adb devices

echo ""
echo "✅ Setup complete!"
echo "📱 Your phone IP: $PHONE_IP"
echo "🔌 You can now unplug the USB cable"
echo "🚀 Run 'scrcpy' to start wireless screen mirroring"
echo ""
echo "💡 To reconnect later: adb connect $PHONE_IP:5555"
