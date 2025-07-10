#!/bin/bash

# Path to the .env file
ENV_FILE="/Users/snirradomsky/workspace/ido-server/env/ci/ido-integration-tests/.env"

# Read the .env file and format the variables, excluding comments and empty lines
formatted_vars=$(grep -v '^\s*#' "$ENV_FILE" | grep -v '^\s*$' | sed 's/\s*#.*//' | tr '\n' ';')

# Remove the trailing semicolon
formatted_vars=${formatted_vars%;};

# Print the formatted variables
echo "$formatted_vars"