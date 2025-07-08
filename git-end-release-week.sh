#!/bin/bash

# Store the script's directory
script_dir=$(cd $( dirname ${BASH_SOURCE[0]} ) && pwd )

# State file to store the last command and week number
STATE_FILE="/tmp/git_end_release_week_state"

# Function to load state
load_state() {
    if [ -f "$STATE_FILE" ]; then
        source "$STATE_FILE"
    else
        LAST_RELEASE_COMMAND=""
        LAST_RELEASE_WEEK=""
    fi
}

# Function to save state
save_state() {
    echo "LAST_RELEASE_COMMAND='$1'" > "$STATE_FILE"
    echo "LAST_RELEASE_WEEK='$2'" >> "$STATE_FILE"
}

# Function to show continue command
show_continue_command() {
    if [ -n "$LAST_RELEASE_COMMAND" ]; then
        echo -e "\n\033[33mLast executed command was: $LAST_RELEASE_COMMAND\033[0m"
        echo -e "\033[33mTo continue from last point, run:\033[0m"
        echo -e "\033[36m~/scripts/git-end-release-week.sh $WEEK_NUMBER\033[0m"
    fi
}

# Function to handle script termination
handle_termination() {
    echo -e "\nScript terminated."
    if [ -n "$cmd" ]; then
        # If we're in the middle of a command, save the previous command
        save_state "${commands[$((i-1))]}" "$WEEK_NUMBER"
    else
        # If we're not in a command, save the current state
        save_state "$LAST_RELEASE_COMMAND" "$WEEK_NUMBER"
    fi
    show_continue_command
    exit 1
}

# Set up trap for script termination
trap handle_termination INT TERM

# Change to the current working directory
cd "$(pwd)"

# Get week number from command line argument or use default value 44
WEEK_NUMBER=${1:-01}

# Load previous state
load_state

# Check if we're continuing from the same week
if [ -n "$LAST_RELEASE_WEEK" ] && [ "$LAST_RELEASE_WEEK" != "$WEEK_NUMBER" ]; then
    echo "Warning: Last execution was for week $LAST_RELEASE_WEEK, but current execution is for week $WEEK_NUMBER"
    echo "Continuing from the beginning..."
    LAST_RELEASE_COMMAND=""
    save_state "" ""
fi

# Display the week number being used
echo "Using week number: $WEEK_NUMBER"

# If we're continuing, show the last command that was executed and prompt for choice
if [ -n "$LAST_RELEASE_COMMAND" ]; then
    echo -e "\033[33mLast executed command was: $LAST_RELEASE_COMMAND\033[0m"
    while true; do
        read -p "Do you want to continue from last point? ([Y]/n - yes/no): " response
        response=$(echo "$response" | tr '[:upper:]' '[:lower:]')
        case $response in
            ""|y*)
                echo -e "\033[33mContinuing from last point...\033[0m"
                break
                ;;
            n*)
                echo "Starting from beginning..."
                LAST_RELEASE_COMMAND=""
                save_state "" ""
                break
                ;;
            *)
                echo "Invalid input. Please enter Y (yes) or N (no). Enter for yes."
                ;;
        esac
    done
fi

# Function to prompt for confirmation
confirm_command() {
    local command=$1
    while true; do
        # Using ANSI color codes: cyan for the command
        echo -e "\nAbout to execute: \033[36m$command\033[0m"
        read -p "Continue? ([Y]/n/s - yes/no/skip): " response
        
        # Convert response to lowercase using tr
        response=$(echo "$response" | tr '[:upper:]' '[:lower:]')
        
        case $response in
            ""|y*)
                return 0  # Continue
                ;;
            n*)
                echo "Aborting script."
                save_state "$LAST_RELEASE_COMMAND" "$WEEK_NUMBER"
                show_continue_command
                exit 1  # Abort
                ;;
            s*)
                return 2  # Skip
                ;;
            *)
                echo "Invalid input. Please enter Y (yes), N (no), or S (skip). Enter for yes."
                ;;
        esac
    done
}

# Function to safely delete branch
safe_delete_branch() {
    local branch=$1
    if git show-ref --verify --quiet refs/heads/$branch; then
        current_branch=$(git rev-parse --abbrev-ref HEAD)
        if [ "$current_branch" = "$branch" ]; then
            echo "Cannot delete currently checked out branch. Switching to master first..."
            git checkout master
        fi
        git branch -D $branch
    else
        echo "Branch $branch does not exist locally"
    fi
}

# Array of commands to execute
commands=(
    "ssh-add ~/.ssh/github_no_pass"
    "git fetch --tags -f"
    "safe_delete_branch release/ido-2025-${WEEK_NUMBER}"
    "git checkout -b release/ido-2025-${WEEK_NUMBER} origin/release/ido-2025-${WEEK_NUMBER}"
    "safe_delete_branch develop"
    "safe_delete_branch master"
    "git tag ido-2025-${WEEK_NUMBER}"
    "git push --tags"
    "git checkout -b master origin/master"
    "git merge origin/release/ido-2025-${WEEK_NUMBER}"
    "git push origin master"
    "git checkout -b develop origin/develop"
    "git merge origin/master"
    "git push origin develop"
)

# Find the starting point if continuing
start_index=0
if [ -n "$LAST_RELEASE_COMMAND" ]; then
    for i in "${!commands[@]}"; do
        if [ "${commands[$i]}" = "$LAST_RELEASE_COMMAND" ]; then
            start_index=$((i + 1))
            break
        fi
    done
fi

# Execute each command with confirmation
for ((i=start_index; i<${#commands[@]}; i++)); do
    cmd="${commands[$i]}"
    confirm_command "$cmd"
    confirm_result=$?
    if [ $confirm_result -eq 0 ]; then
        if [[ $cmd == "safe_delete_branch"* ]]; then
            # For safe_delete_branch commands, don't exit on error
            eval "$cmd" || echo "Branch deletion failed, continuing..."
        else
            # Save state before executing command
            save_state "$cmd" "$WEEK_NUMBER"
            # Set up trap for command execution
            trap handle_termination INT TERM
            eval "$cmd"
            cmd_result=$?
            # Restore original trap
            trap - INT TERM
            if [ $cmd_result -ne 0 ]; then
                echo "Error executing: $cmd"
                echo "Script terminated."
                save_state "${commands[$((i-1))]}" "$WEEK_NUMBER"
                show_continue_command
                exit 1
            fi
        fi
    elif [ $confirm_result -eq 2 ]; then
        echo "Skipped: $cmd"
    else
        # This shouldn't happen due to the loop in confirm_command,
        # but it's here for completeness
        echo "Aborted."
        save_state "$LAST_RELEASE_COMMAND" "$WEEK_NUMBER"
        show_continue_command
        exit 1
    fi
done

# Clean up state file on successful completion
rm -f "$STATE_FILE"

# Calculate next week number
NEXT_WEEK=$(printf "%02d" $((10#$WEEK_NUMBER + 1)))

echo -e "Next release branch will be: \033[1;32mrelease/ido-2025-${NEXT_WEEK}\033[0m"
echo -e "Next version will be: \033[1;36m25.${NEXT_WEEK}.0\033[0m"
echo -e "\033[1;33mDon't forget to update the version in: server/src/main/resources/version\033[0m"

echo "Script completed successfully."
