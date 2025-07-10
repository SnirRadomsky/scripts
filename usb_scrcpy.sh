#!/bin/bash

# USB-only scrcpy script - most reliable option

echo "📱 USB scrcpy launcher"
echo "===================="

# Check if USB device is connected
USB_DEVICE=$(adb devices | grep -v ":5555" | grep "device$")

if [ -z "$USB_DEVICE" ]; then
    echo "❌ No USB device detected"
    echo "💡 Please:"
    echo "   1. Connect USB cable"
    echo "   2. Set to 'File Transfer' mode" 
    echo "   3. Accept USB debugging authorization"
    exit 1
fi

echo "✅ USB device detected"
echo "📋 Connected devices:"
adb devices

echo "🚀 Launching scrcpy via USB..."
echo "   (Close window or press Ctrl+C to exit)"
echo ""

# Launch scrcpy with USB-optimized settings
scrcpy --max-fps 60 --video-bit-rate 8M --stay-awake --window-title "Android (USB)"