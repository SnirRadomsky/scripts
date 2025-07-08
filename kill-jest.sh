#!/bin/bash
# This script kills all processes that include "jest" in their command line.

echo "Killing all 'jest' processes..."
pkill -f jest

if [ $? -eq 0 ]; then
  echo "'jest' processes terminated successfully."
else
  echo "No 'jest' processes found or an error occurred."
fi
