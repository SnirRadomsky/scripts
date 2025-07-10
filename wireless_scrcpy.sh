#!/bin/bash

# Script to connect to phone wirelessly and launch scrcpy

echo "📱 Wireless scrcpy connection script"
echo "=================================="

# Check if adb is available
if ! command -v adb &> /dev/null; then
    echo "❌ ADB not found. Please install Android platform tools."
    exit 1
fi

# Check if scrcpy is available
if ! command -v scrcpy &> /dev/null; then
    echo "❌ scrcpy not found. Please install scrcpy."
    exit 1
fi

echo "🔍 Checking for connected devices..."

# Check if any device is connected (including offline ones)
DEVICES=$(adb devices | tail -n +2 | grep -v "^$" | wc -l)
ONLINE_DEVICES=$(adb devices | grep -c "device$")

if [ "$DEVICES" -eq 0 ]; then
    echo "❌ No phone detected. Please connect via USB first."
    echo "   1. Connect phone via USB"
    echo "   2. Enable USB debugging"
    echo "   3. Accept debugging authorization"
    echo "   4. Set USB to 'File Transfer' mode"
    exit 1
fi

if [ "$ONLINE_DEVICES" -eq 0 ]; then
    echo "⚠️  Devices detected but all are offline"
    echo "🧹 Cleaning up offline connections..."
    
    # Clean up offline wireless connections
    adb devices | grep ":5555" | grep "offline" | awk '{print $1}' | while read device; do
        echo "Disconnecting offline device: $device"
        adb disconnect "$device"
    done
    
    # Restart ADB
    adb kill-server
    sleep 2
    adb start-server
    
    # Check again
    ONLINE_DEVICES=$(adb devices | grep -c "device$")
    if [ "$ONLINE_DEVICES" -eq 0 ]; then
        echo "❌ No online devices after cleanup. Please connect via USB."
        exit 1
    fi
fi

echo "✅ Device detected"

# Check if already connected wirelessly
WIRELESS_DEVICE=$(adb devices | grep ":5555" | grep "device$")
USB_DEVICE=$(adb devices | grep -v ":5555" | grep "device$")

# If both USB and wireless are connected, disconnect USB first
if [ ! -z "$WIRELESS_DEVICE" ] && [ ! -z "$USB_DEVICE" ]; then
    echo "📡 Found both USB and wireless connections"
    echo "🔌 Disconnecting USB to avoid conflicts..."
    USB_ID=$(echo "$USB_DEVICE" | awk '{print $1}')
    adb disconnect "$USB_ID" 2>/dev/null
    sleep 1
fi

# Check again for wireless connection
WIRELESS_DEVICE=$(adb devices | grep ":5555" | grep "device$")
if [ ! -z "$WIRELESS_DEVICE" ]; then
    echo "📡 Using existing wireless connection!"
    PHONE_IP=$(echo "$WIRELESS_DEVICE" | awk '{print $1}' | cut -d':' -f1)
    echo "📱 Phone IP: $PHONE_IP"
    echo ""
    echo "🚀 Launching scrcpy..."
    echo "   (Close scrcpy window or press Ctrl+C to exit)"
    echo ""
    scrcpy
    exit 0
fi

# If not wireless, must be USB - get the WiFi IP
echo "🔍 Getting phone's WiFi IP address..."
echo "💡 Make sure your phone is connected to WiFi and USB is set to 'File Transfer' mode"

# Try multiple methods to get IP
PHONE_IP=""

# Method 1: Check wlan0
PHONE_IP=$(adb shell ip addr show wlan0 2>/dev/null | grep "inet " | awk '{print $2}' | cut -d'/' -f1)

# Method 2: If wlan0 doesn't work, try other interfaces
if [ -z "$PHONE_IP" ]; then
    PHONE_IP=$(adb shell ip route get 8.8.8.8 2>/dev/null | grep -oE 'src [0-9.]+' | cut -d' ' -f2)
fi

# Method 3: Try ifconfig
if [ -z "$PHONE_IP" ]; then
    PHONE_IP=$(adb shell ifconfig 2>/dev/null | grep -A 1 wlan0 | grep 'inet addr' | cut -d: -f2 | awk '{print $1}')
fi

if [ -z "$PHONE_IP" ]; then
    echo "❌ Cannot get phone's WiFi IP address."
    echo "   Please make sure:"
    echo "   1. Phone is connected to WiFi"
    echo "   2. USB is set to 'File Transfer' mode"
    echo "   3. Try disconnecting and reconnecting USB"
    exit 1
fi

echo "📱 Phone IP found: $PHONE_IP"

# Set up TCP mode
echo "🔧 Setting up wireless connection..."
adb tcpip 5555

# Wait a moment for the restart
echo "⏳ Waiting for TCP mode to initialize..."
sleep 3

# Connect wirelessly
echo "📡 Connecting wirelessly to $PHONE_IP:5555..."
CONNECT_RESULT=$(adb connect $PHONE_IP:5555)
echo "$CONNECT_RESULT"

# Wait a moment for connection to establish
sleep 2

# Check if wireless connection is successful
echo "🔍 Checking wireless connection..."
adb devices

WIRELESS_CONNECTED=$(adb devices | grep "$PHONE_IP:5555" | grep -c "device$")
if [ "$WIRELESS_CONNECTED" -eq 0 ]; then
    echo "❌ Wireless connection failed. Please try again."
    exit 1
fi

echo "✅ Wireless connection successful!"

# Disconnect USB connection to avoid conflicts
echo "🔌 Disconnecting USB connection to avoid conflicts..."
USB_DEVICE=$(adb devices | grep -v "$PHONE_IP:5555" | grep "device$" | awk '{print $1}')
if [ ! -z "$USB_DEVICE" ]; then
    adb disconnect "$USB_DEVICE" 2>/dev/null
fi

# Wait a moment for cleanup
sleep 1

echo ""
echo "✅ Setup complete!"
echo "📱 Phone IP: $PHONE_IP"
echo "🔌 You can now unplug the USB cable"
echo ""
echo "🚀 Launching scrcpy..."
echo "   (Close scrcpy window or press Ctrl+C to exit)"
echo ""

# Launch scrcpy with stability improvements
scrcpy --max-fps 30 --video-bit-rate 4M --stay-awake

echo ""
echo "🔚 scrcpy closed"
echo "💡 To reconnect later: adb connect $PHONE_IP:5555 && scrcpy"