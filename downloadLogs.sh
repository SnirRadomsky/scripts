#!/bin/bash

# Define the downloads folder
DOWNLOADS_DIR="$HOME/Downloads"

# Find the most recent log file in the Downloads folder from the last 10 minutes - optimized version for macOS
LATEST_LOG=$(ls -t "$DOWNLOADS_DIR"/*.{log,txt} 2>/dev/null | grep -E "\.log$|ido.*\.txt$" | head -n1)

# If no log file is found, exit
if [ -z "$LATEST_LOG" ] || [ ! -f "$LATEST_LOG" ]; then
    echo "No log file found in Downloads from the last 10 minutes."
    exit 1
fi

# Check if file is older than 10 minutes
if [ $(( $(date +%s) - $(stat -f %m "$LATEST_LOG") )) -gt 600 ]; then
    echo "No log file found in Downloads from the last 10 minutes."
    exit 1
fi

# Log the original file name
echo "Found log file: $LATEST_LOG"

# Create a unique filename with a .log extension
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
NEW_LOG_FILE="$DOWNLOADS_DIR/argocd_logs_$TIMESTAMP.log"

# Rename the log file
mv "$LATEST_LOG" "$NEW_LOG_FILE"

# Define all patterns to exclude in a single grep pattern
EXCLUDE_PATTERNS="NettyClientHandler|GcpPubSubReportsProvider|ThreadId|FlushingBatch|SslHandler|PolicyTemplatesGetMetadata|Failed to parse expression at index: 0, expected: \" \\t\\n\"|unexpected error when trying to read policy templates"

# Create filtered log files in a single pass
FILTERED_LOG_FILE="$DOWNLOADS_DIR/argocd_logs_filtered_$TIMESTAMP.log"
ERROR_LOG_FILE="$DOWNLOADS_DIR/argocd_logs_errors_$TIMESTAMP.log"

# First create the filtered log (excluding unwanted patterns)
LC_ALL=C grep -vE "$EXCLUDE_PATTERNS" "$NEW_LOG_FILE" > "$FILTERED_LOG_FILE"

# Then create the error log from the filtered log
LC_ALL=C grep "ERROR" "$FILTERED_LOG_FILE" > "$ERROR_LOG_FILE"

# If a custom grep pattern is provided, create a custom filtered file
if [ $# -eq 1 ]; then
    CUSTOM_LOG_FILE="$DOWNLOADS_DIR/argocd_logs_custom_$TIMESTAMP.log"
    LC_ALL=C grep "$1" "$FILTERED_LOG_FILE" > "$CUSTOM_LOG_FILE"
    echo "Custom filtered log: $CUSTOM_LOG_FILE"
    # Open all three logs in VS Code
    code "$ERROR_LOG_FILE" "$FILTERED_LOG_FILE" "$CUSTOM_LOG_FILE" &
else
    # If no custom pattern, open just the error and filtered logs
    code "$ERROR_LOG_FILE" "$FILTERED_LOG_FILE" &
fi

# Print filenames for reference
echo "Filtered log: $FILTERED_LOG_FILE"
echo "Filtered error log: $ERROR_LOG_FILE"