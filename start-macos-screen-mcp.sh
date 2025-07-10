#!/bin/bash
source ~/.venvs/macos-screen/bin/activate
nohup python -m macos_screen_mcp > ~/.macos-screen-mcp.log 2>&1 &
echo "MCP server started with PID $!"