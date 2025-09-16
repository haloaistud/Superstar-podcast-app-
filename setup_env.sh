#!/bin/bash

ENV_FILE=".env"
EXAMPLE_FILE=".env.example"

# --- Helper Functions ---
validate_url() { [[ $1 =~ ^https?://.+ ]] && return 0 || return 1; }
validate_secret() { [[ -n "$1" ]] && return 0 || return 1; }
validate_port() { [[ "$1" =~ ^[0-9]+$ ]] && [ "$1" -ge 1 ] && [ "$1" -le 65535 ] && return 0 || return 1; }
validate_email() { [[ "$1" =~ ^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$ ]] && return 0 || return 1; }

prompt_input() {
    local VAR_NAME=$1
    local VALIDATOR=$2
    local VALUE
    local RETRIES=3
    for ((i=1;i<=RETRIES;i++)); do
        read -p "Enter value for $VAR_NAME: " VALUE
        if [ -z "$VALUE" ]; then echo "Value cannot be empty."; continue; fi
        if [ "$VALIDATOR" == "url" ] && ! validate_url "$VALUE"; then echo "Invalid URL."; continue; fi
        if [ "$VALIDATOR" == "port" ] && ! validate_port "$VALUE"; then echo "Invalid port."; continue; fi
        if [ "$VALIDATOR" == "email" ] && ! validate_email "$VALUE"; then echo "Invalid email."; continue; fi
        if [ "$VALIDATOR" == "secret" ] && ! validate_secret "$VALUE"; then echo "Cannot be empty."; continue; fi
        echo "$VALUE"; return 0
    done
    echo "Failed to provide valid input for $VAR_NAME"; exit 1
}

escape_sed() { echo "$1" | sed 's/[\/&]/\\&/g'; }

# --- Start Script ---
if [ ! -f "$EXAMPLE_FILE" ]; then echo "Error: $EXAMPLE_FILE not found!"; exit 1; fi
[ -f "$ENV_FILE" ] && cp "$ENV_FILE" ".env.bak"
cp "$EXAMPLE_FILE" "$ENV_FILE"
echo "Created $ENV_FILE from $EXAMPLE_FILE"

while IFS= read -r line || [ -n "$line" ]; do
    [[ -z "$line" || "$line" == \#* ]] && continue
    VAR_NAME=$(echo "$line" | cut -d '=' -f1)
    VAR_VALUE=$(grep "^$VAR_NAME=" "$ENV_FILE" | cut -d '=' -f2-)
    if [ -z "$VAR_VALUE" ]; then
        case "$VAR_NAME" in
            *URI*|*URL*) VALIDATOR="url" ;;
            *SECRET*|*KEY*|*TOKEN*) VALIDATOR="secret" ;;
            *PORT*) VALIDATOR="port" ;;
            *EMAIL*|*USER*) VALIDATOR="email" ;;
            *) VALIDATOR="secret" ;;
        esac
        INPUT_VALUE=$(prompt_input "$VAR_NAME" "$VALIDATOR")
        ESCAPED_VALUE=$(escape_sed "$INPUT_VALUE")
        sed -i "s/^$VAR_NAME=.*/$VAR_NAME=$ESCAPED_VALUE/" "$ENV_FILE"
    fi
done < "$EXAMPLE_FILE"

echo ".env setup complete!"
