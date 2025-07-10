#!/usr/bin/env bash

if [ -z $SKIP_BUILD ]; then
    npm init -y
    npm install mongodb
fi

# Source the nvm setup script to load nvm into the script's environment
source ~/.nvm/nvm.sh

### Uncomment these lines to use the latest Node.js LTS version in case mongodb commands fail on your current Node.js version
## Install the latest Node.js version
nvm install node 2>&1
## Switch to the latest Node.js version
nvm use node 2>&1

db_name="${1:-test}"

DB_NAME="$db_name" node ido_811_migrateToLowerCase.js
DB_NAME="$db_name" node ido_812_migrateActionFailureId.js
DB_NAME="$db_name" node ido_812_migrateWebauthnPassKeys.js