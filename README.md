# Scripts Collection

This repository contains a collection of useful shell scripts and aliases for development and system administration tasks.

## Scripts Overview

### Network and Connection Scripts
- `wifi_connect.sh` - Script for connecting to WiFi networks
- `wireless_scrcpy.sh` - Script for wireless screen mirroring with scrcpy
- `file_transfer.sh` - File transfer utilities
- `quick_reconnect.sh` - Quick network reconnection script
- `connection_health.sh` - Network connection health checker
- `get_phone_ip.sh` - Get phone IP address

### Development Scripts
- `code-review-local.py` - Local code review automation
- `git-end-release-week.sh` - Git workflow for release week
- `git-workflow-script.sh_old` - Legacy Git workflow script
- `modifyJWTExpirationDate.py` - JWT token expiration date modifier
- `unify_journeys.sh` - Journey unification script
- `kill-jest.sh` - Jest process killer

### Data Management Scripts
- `tenant-dump.sh` - Tenant data dumping utility
- `tenant-restore.sh` - Tenant data restoration utility
- `convertJsonWithNewLines.sh` - JSON formatting with newlines
- `downloadLogs.sh` - Log downloading utility

### System Scripts
- `organize_home.sh` - Home directory organization
- `move_archives.sh` - Archive file management
- `move_test_archives.sh` - Test archive management
- `newScript.sh` - New script template generator
- `restart-macos-screen.sh` - macOS screen restart
- `start-macos-screen-mcp.sh` - macOS screen MCP starter
- `format-it-envs.sh` - Environment formatting script

## Aliases

The following aliases are available for quick access to common commands and scripts:

### Network and Connection Aliases
```bash
alias wifiConnect="/Users/snirradomsky/scripts/wifi_connect.sh"
alias wificonnect=wifiConnect
alias wireless-scrcpy="~/scripts/wireless_scrcpy.sh"
alias transfer-files="~/scripts/file_transfer.sh"
alias quick-reconnect="~/scripts/quick_reconnect.sh"
alias check-connection="~/scripts/connection_health.sh"
```

### Development Environment Aliases
```bash
alias iterm='function _iterm() { open -a "iTerm" "$1"; };_iterm'
alias idea='idea > /dev/null 2>&1'
alias node18="$HOME/.nvm/versions/node/v18.12.1/bin/node"
alias npm18="$HOME/.nvm/versions/node/v18.12.1/bin/npm"
alias npx18="$HOME/.nvm/versions/node/v18.12.1/bin/npx"
```

### Database and Data Management Aliases
```bash
alias ts-dump='/Users/snirradomsky/workspace/ido-server/env/ci/integration-tests/tools/mongo/ts-dump.sh'
alias ts-restore='/Users/snirradomsky/workspace/ido-server/env/ci/integration-tests/tools/mongo/ts-restore.sh'
alias ts-truncate='/Users/snirradomsky/workspace/ido-server/env/ci/integration-tests/tools/ts-truncate.sh'
alias json-dump='/Users/snirradomsky/scripts/json-dump/json-dump.sh'
alias json-restore='/Users/snirradomsky/scripts/json-dump/json-restore.sh'
alias tenant-dump='/Users/snirradomsky/scripts/tenant-dump.sh'
alias tenant-restore='/Users/snirradomsky/scripts/tenant-restore.sh'
```

### Environment Configuration Aliases
```bash
alias replaceEnv='sed -i "" "s|VITE_IDO_SERVER_URL=\"https://api.idsec-stg.com/ido\"|VITE_IDO_SERVER_URL=\"http://localhost:8080/ido\"|g" .env && sed -i "" "s|VITE_CLIENT_ID=\"The client ID of your admin portal application\"|VITE_CLIENT_ID=\"3uhhljh4cqd7ip5hyecw9wx4javi3gzo\"|g" .env'
alias codegenRun="sed -i '' 's|VITE_SERVER_PATH=\"https://api.idsec-stg.com/ido\"|VITE_SERVER_PATH=\"http://localhost:8080/ido\"|g' .env && sed -i '' 's|VITE_CLIENT_ID=\"The client ID of your admin portal application\"|VITE_CLIENT_ID=\"3uhhljh4cqd7ip5hyecw9wx4javi3gzo\"|g' .env && npm i && npm run start"
alias codegenRunNew="sed -i '' 's|VITE_IDO_SERVER_URL=\"https://api.idsec-stg.com/ido\"|VITE_IDO_SERVER_URL=\"http://localhost:8080/ido\"|g' .env && sed -i '' 's|VITE_CLIENT_ID=\"The client ID of your admin portal application\"|VITE_CLIENT_ID=\"3uhhljh4cqd7ip5hyecw9wx4javi3gzo\"|g' .env && npm i && npm run start"
alias runCodegen=codegenRunNew
alias runcodegen=runCodegen
```

### SSO Hosted Application Aliases
```bash
alias sso-hosted-local="cd /Users/snirradomsky/workspace/ido-sso-hosted && yarn dev"
alias sso-hosted-dev="cd /Users/snirradomsky/workspace/ido-sso-hosted && env \$(grep -v \"^#\" /Users/snirradomsky/workspace/ido-sso-hosted/.env.dev | xargs) yarn dev"
alias sso-hosted-stg="cd /Users/snirradomsky/workspace/ido-sso-hosted && env \$(grep -v \"^#\" /Users/snirradomsky/workspace/ido-sso-hosted/.env.stg | xargs) yarn dev"
alias sso-hosted-ms-sbx="cd /Users/snirradomsky/workspace/ido-sso-hosted && env \$(grep -v \"^#\" /Users/snirradomsky/workspace/ido-sso-hosted/.env.ms-sbx | xargs) yarn dev"
alias sso-hosted-sbx="cd /Users/snirradomsky/workspace/ido-sso-hosted && env \$(grep -v \"^#\" /Users/snirradomsky/workspace/ido-sso-hosted/.env.sbx | xargs) yarn dev"
alias sso-hosted-prod="cd /Users/snirradomsky/workspace/ido-sso-hosted && env \$(grep -v \"^#\" /Users/snirradomsky/workspace/ido-sso-hosted/.env.prod | xargs) yarn dev"
alias sso-hosted-prod-ca="cd /Users/snirradomsky/workspace/ido-sso-hosted && env \$(grep -v \"^#\" /Users/snirradomsky/workspace/ido-sso-hosted/.env.prod-ca | xargs) yarn dev"
alias sso-hosted-prod-eu="cd /Users/snirradomsky/workspace/ido-sso-hosted && env \$(grep -v \"^#\" /Users/snirradomsky/workspace/ido-sso-hosted/.env.prod-eu | xargs) yarn dev"
alias sso-hosted-test="cd /Users/snirradomsky/workspace/ido-sso-hosted && env \$(grep -v \"^#\" /Users/snirradomsky/workspace/ido-sso-hosted/.env.test | xargs) yarn dev"
```

## Installation

To automatically add all aliases to your `.zshrc` file, run:

```bash
./install_aliases.sh
```

## Usage

1. Clone this repository
2. Make scripts executable: `chmod +x *.sh`
3. Run the alias installation script: `./install_aliases.sh`
4. Reload your shell: `source ~/.zshrc`

## Directory Structure

```
scripts/
├── README.md
├── install_aliases.sh
├── hooks/
├── ido_migrations/
├── json-dump/
├── temp/
└── [various .sh and .py scripts]
```

## Contributing

When adding new scripts:
1. Make them executable: `chmod +x script_name.sh`
2. Add appropriate documentation
3. Update aliases in both `.zshrc` and `install_aliases.sh`
4. Test thoroughly before committing

## License

This collection is for personal use and development workflow optimization.
