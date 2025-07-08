#!/bin/bash

# Make sure we have execute permissions
chmod +x "$0"

# Script to organize home directory loose files
# Note: This script will NOT touch existing directories or dot files (system config files)

BASE_DIR="/Users/snirradomsky"
TO_REMOVE_DIR="$BASE_DIR/toRemove"
ARCHIVES_DIR="$BASE_DIR/Archives"
SCRIPTS_DIR="$BASE_DIR/Scripts"
DEV_FILES_DIR="$BASE_DIR/Development_Files"

echo "Starting home directory organization..."
echo "Note: Keeping all existing directories and dot files untouched"

# Move archive files (.tgz, .tar, .zip) to Archives
echo "Moving archive files to Archives..."
find "$BASE_DIR" -maxdepth 1 -name "*.tgz" -type f | while read file; do
    filename=$(basename "$file")
    echo "Moving $filename to Archives..."
    mv "$file" "$ARCHIVES_DIR/" 2>/dev/null
done

find "$BASE_DIR" -maxdepth 1 -name "*.tar" -type f | while read file; do
    filename=$(basename "$file")
    echo "Moving $filename to Archives..."
    mv "$file" "$ARCHIVES_DIR/" 2>/dev/null
done

find "$BASE_DIR" -maxdepth 1 -name "*.zip" -type f | while read file; do
    filename=$(basename "$file")
    echo "Moving $filename to Archives..."
    mv "$file" "$ARCHIVES_DIR/" 2>/dev/null
done

# Move script files to Scripts
echo "Moving script files to Scripts..."
find "$BASE_DIR" -maxdepth 1 -name "*.sh" -type f | while read file; do
    filename=$(basename "$file")
    echo "Moving $filename to Scripts..."
    mv "$file" "$SCRIPTS_DIR/" 2>/dev/null
done

# Move development files to Development_Files
echo "Moving development files to Development_Files..."
find "$BASE_DIR" -maxdepth 1 -name "*.patch" -type f | while read file; do
    filename=$(basename "$file")
    echo "Moving $filename to Development_Files..."
    mv "$file" "$DEV_FILES_DIR/" 2>/dev/null
done

find "$BASE_DIR" -maxdepth 1 -name "*.json" -type f | while read file; do
    filename=$(basename "$file")
    echo "Moving $filename to Development_Files..."
    mv "$file" "$DEV_FILES_DIR/" 2>/dev/null
done

# Move specific development files
mv "$BASE_DIR/pubsub-credentials" "$DEV_FILES_DIR/" 2>/dev/null
mv "$BASE_DIR/java_error_in_idea.hprof" "$DEV_FILES_DIR/" 2>/dev/null
mv "$BASE_DIR/intellij-errors.txt" "$DEV_FILES_DIR/" 2>/dev/null

# Move HTML files to Development_Files (they appear to be exports/reports)
find "$BASE_DIR" -maxdepth 1 -name "*.html" -type f | while read file; do
    filename=$(basename "$file")
    echo "Moving $filename to Development_Files..."
    mv "$file" "$DEV_FILES_DIR/" 2>/dev/null
done

# Move log files to toRemove (old logs can be deleted)
echo "Moving log files to toRemove..."
find "$BASE_DIR" -maxdepth 1 -name "*.log" -type f | while read file; do
    filename=$(basename "$file")
    echo "Moving $filename to toRemove..."
    mv "$file" "$TO_REMOVE_DIR/" 2>/dev/null
done

# Move test failure files and other temporary files to toRemove
echo "Moving temporary/test files to toRemove..."
mv "$BASE_DIR/========== FAILED TESTS ==========" "$TO_REMOVE_DIR/" 2>/dev/null

echo "Home directory organization complete!"
echo ""
echo "Summary:"
echo "- Archive files (.tgz, .tar, .zip) moved to: $ARCHIVES_DIR"
echo "- Script files (.sh) moved to: $SCRIPTS_DIR" 
echo "- Development files (.patch, .json, .html) moved to: $DEV_FILES_DIR"
echo "- Log files and test files moved to: $TO_REMOVE_DIR"
echo "- All existing directories left untouched"
echo "- All dot files (system config) left untouched"
