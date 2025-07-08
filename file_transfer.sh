#!/bin/bash

# File transfer script for Android phone

echo "📱💻 Android File Transfer Script"
echo "================================"

# Check if adb is available
if ! command -v adb &> /dev/null; then
    echo "❌ ADB not found. Please install Android platform tools."
    exit 1
fi

# Check if device is connected
DEVICES=$(adb devices | grep -c "device$")
if [ "$DEVICES" -eq 0 ]; then
    echo "❌ No phone detected. Please connect via USB or wireless."
    exit 1
fi

echo "✅ Device connected"
echo ""

# Show menu
echo "Choose transfer direction:"
echo "1. 📤 Send file TO phone (laptop → phone)"
echo "2. 📥 Get file FROM phone (phone → laptop)"
echo "3. 📋 List phone directories"
echo "4. 🔍 Find files on phone"
echo ""
read -p "Enter choice (1-4): " choice

case $choice in
    1)
        echo ""
        echo "📤 Send file TO phone"
        echo "===================="
        read -p "Enter full path to file on laptop: " laptop_file
        
        if [ ! -f "$laptop_file" ]; then
            echo "❌ File not found: $laptop_file"
            exit 1
        fi
        
        echo ""
        echo "Common phone destinations:"
        echo "1. /sdcard/Download/ (Downloads folder)"
        echo "2. /sdcard/DCIM/Camera/ (Camera folder)"
        echo "3. /sdcard/Pictures/ (Pictures folder)"
        echo "4. /sdcard/Documents/ (Documents folder)"
        echo "5. Custom path"
        echo ""
        read -p "Choose destination (1-5): " dest_choice
        
        case $dest_choice in
            1) phone_path="/sdcard/Download/" ;;
            2) phone_path="/sdcard/DCIM/Camera/" ;;
            3) phone_path="/sdcard/Pictures/" ;;
            4) phone_path="/sdcard/Documents/" ;;
            5) read -p "Enter custom path: " phone_path ;;
            *) echo "❌ Invalid choice"; exit 1 ;;
        esac
        
        echo "🚀 Transferring file..."
        if adb push "$laptop_file" "$phone_path"; then
            echo "✅ File transferred successfully!"
            echo "📱 Location: $phone_path$(basename "$laptop_file")"
        else
            echo "❌ Transfer failed"
        fi
        ;;
        
    2)
        echo ""
        echo "📥 Get file FROM phone"
        echo "====================="
        read -p "Enter full path to file on phone: " phone_file
        read -p "Enter destination folder on laptop: " laptop_folder
        
        if [ ! -d "$laptop_folder" ]; then
            echo "❌ Destination folder not found: $laptop_folder"
            exit 1
        fi
        
        echo "🚀 Transferring file..."
        if adb pull "$phone_file" "$laptop_folder/"; then
            echo "✅ File transferred successfully!"
            echo "💻 Location: $laptop_folder/$(basename "$phone_file")"
        else
            echo "❌ Transfer failed"
        fi
        ;;
        
    3)
        echo ""
        echo "📋 Phone directories"
        echo "==================="
        echo "Common folders:"
        echo ""
        echo "📁 /sdcard/Download/"
        adb shell ls -la /sdcard/Download/ | head -10
        echo ""
        echo "📁 /sdcard/DCIM/Camera/"
        adb shell ls -la /sdcard/DCIM/Camera/ | head -10
        echo ""
        echo "📁 /sdcard/Pictures/"
        adb shell ls -la /sdcard/Pictures/ | head -10
        ;;
        
    4)
        echo ""
        echo "🔍 Find files on phone"
        echo "====================="
        read -p "Enter filename to search for: " search_term
        echo "Searching..."
        adb shell find /sdcard -name "*$search_term*" -type f 2>/dev/null | head -20
        ;;
        
    *)
        echo "❌ Invalid choice"
        exit 1
        ;;
esac
