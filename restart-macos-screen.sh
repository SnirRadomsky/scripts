#!/bin/bash

# Kill any existing instances
pkill -f "python -m macos_screen_mcp" || true

# Activate virtual environment and start server
source ~/.venvs/macos-screen/bin/activate
python -m macos_screen_mcp