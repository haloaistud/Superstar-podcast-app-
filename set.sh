#!/bin/bash

# Superstar Podcast Hub - Full-scale Environment Setup Script

ENV_FILE=".env"
EXAMPLE_FILE=".env.example"

# --- Helper Functions ---

# Validate URL (simple check)
validate_url() {
    [[ $1 =~ ^https?://.+ ]] && return 0 || return 1
}

# Validate non-empty secret/key
validate_secret() {
    [[ -n "$1" ]] && return 0 || return 1
}

# Validate integer/port
validate_port() {
    [[ "$1" =~ ^[0-9]+$ ]] && [ "$1" -ge 1 ] && [ "$1" -le 65535 ] && return 0 || return 1
}

# Validate email
validate_email() {
    [[ "$1" =~ ^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$ ]] && return 0 || return 1
}

# Prompt and validate with retries
prompt_input() {
    local VAR_NAME=$1
    local VALIDATOR=$2
    local VALUE
    local RETRIES=3

    for ((i=1;i<=RETRIES;i++)); do
        read -p "Enter value for $VAR_NAME: " VALUE
        if [ -z "$VALUE" ]; then
            echo "Value cannot be empty."
            continue
        fi
        if [ "$VALIDATOR" == "url" ] && ! validate_url "$VALUE"; then
            echo "Invalid URL format."
        elif [ "$VALIDATOR" == "secret" ] && ! validate_secret "$VALUE"; then
            echo "Secret/key cannot be empty."
        elif [ "$VALIDATOR" == "port" ] && ! validate_port "$VALUE"; then
            echo "Invalid port number."
        elif [ "$VALIDATOR" == "email" ] && ! validate_email "$VALUE"; then
            echo "Invalid email address."
        else
            echo "$VALUE"
            return 0
        fi
    done

    echo "Failed to provide valid input for $VAR_NAME after $RETRIES attempts."
    exit 1
}

# Escape special characters for sed
escape_sed() {
    echo "$1" | sed 's/[\/&]/\\&/g'
}

# --- Start Script ---

# Check for .env.example
if [ ! -f "$EXAMPLE_FILE" ]; then
    echo "Error: $EXAMPLE_FILE not found!"
    exit 1
fi

# Backup existing .env
if [ -f "$ENV_FILE" ]; then
    echo "$ENV_FILE exists. Backing up to .env.bak"
    cp "$ENV_FILE" ".env.bak"
fi

# Copy example to .env
cp "$EXAMPLE_FILE" "$ENV_FILE"
echo "Created $ENV_FILE from $EXAMPLE_FILE"

# Loop through each variable in .env.example
while IFS= read -r line || [ -n "$line" ]; do
    # Skip empty lines or comments
    [[ -z "$line" || "$line" == \#* ]] && continue

    VAR_NAME=$(echo "$line" | cut -d '=' -f1)
    VAR_VALUE=$(grep "^$VAR_NAME=" "$ENV_FILE" | cut -d '=' -f2-)

    # Only prompt if empty
    if [ -z "$VAR_VALUE" ]; then
        # Determine validation type based on variable name
        case "$VAR_NAME" in
            *URI*|*URL*) VALIDATOR="url" ;;
            *SECRET*|*KEY*|*TOKEN*) VALIDATOR="secret" ;;
            *PORT*) VALIDATOR="port" ;;
            *EMAIL*|*USER*) VALIDATOR="email" ;;
            *) VALIDATOR="secret" ;;  # default fallback
        esac

        INPUT_VALUE=$(prompt_input "$VAR_NAME" "$VALIDATOR")
        ESCAPED_VALUE=$(escape_sed "$INPUT_VALUE")
        sed -i "s/^$VAR_NAME=.*/$VAR_NAME=$ESCAPED_VALUE/" "$ENV_FILE"
    fi
done < "$EXAMPLE_FILE"

echo ""
echo "✅ .env setup complete! All required credentials and settings are filled."
echo "You can now proceed to start the backend and frontend."
