#!/bin/bash

# Superstar Podcast Hub - Full Environment Setup Script (Safe Version)
# Automatically creates setup_env.sh if missing, sets up .env, installs dependencies,
# runs migrations (if present) & seeds, and starts backend + frontend.

BACKEND_DIR="src/backend"
FRONTEND_DIR="src/frontend"
SETUP_ENV_SCRIPT="./setup_env.sh"

# --- Step 0: Create setup_env.sh if missing ---
if [ ! -f "$SETUP_ENV_SCRIPT" ]; then
    echo "setup_env.sh not found. Creating it automatically..."
    cat > "$SETUP_ENV_SCRIPT" << 'EOF'
#!/bin/bash
# Dynamic .env setup (same as previous full-featured setup_env.sh)
ENV_FILE=".env"
EXAMPLE_FILE=".env.example"
validate_url() { [[ $1 =~ ^https?://.+ ]] && return 0 || return 1; }
validate_secret() { [[ -n "$1" ]] && return 0 || return 1; }
validate_port() { [[ "$1" =~ ^[0-9]+$ ]] && [ "$1" -ge 1 ] && [ "$1" -le 65535 ] && return 0 || return 1; }
validate_email() { [[ "$1" =~ ^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$ ]] && return 0 || return 1; }
prompt_input() { local VAR_NAME=$1; local VALIDATOR=$2; local VALUE; local RETRIES=3; for ((i=1;i<=RETRIES;i++)); do read -p "Enter value for $VAR_NAME: " VALUE; if [ -z "$VALUE" ]; then echo "Value cannot be empty."; continue; fi; if [ "$VALIDATOR" == "url" ] && ! validate_url "$VALUE"; then echo "Invalid URL."; continue; fi; if [ "$VALIDATOR" == "port" ] && ! validate_port "$VALUE"; then echo "Invalid port."; continue; fi; if [ "$VALIDATOR" == "email" ] && ! validate_email "$VALUE"; then echo "Invalid email."; continue; fi; if [ "$VALIDATOR" == "secret" ] && ! validate_secret "$VALUE"; then echo "Cannot be empty."; continue; fi; echo "$VALUE"; return 0; done; echo "Failed to provide valid input for $VAR_NAME"; exit 1; }
escape_sed() { echo "$1" | sed 's/[\/&]/\\&/g'; }
[ ! -f "$EXAMPLE_FILE" ] && echo "Error: $EXAMPLE_FILE not found!" && exit 1
[ -f "$ENV_FILE" ] && cp "$ENV_FILE" ".env.bak"
cp "$EXAMPLE_FILE" "$ENV_FILE"
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
EOF
    chmod +x "$SETUP_ENV_SCRIPT"
    echo "setup_env.sh created successfully!"
fi

# --- Step 1: Run setup_env.sh ---
echo "=============================="
echo "Step 1: Setting up .env file"
echo "=============================="
bash "$SETUP_ENV_SCRIPT"

# --- Step 2: Install Backend Dependencies ---
echo ""
echo "=============================="
echo "Step 2: Installing backend dependencies"
echo "=============================="
cd "$BACKEND_DIR" || exit 1
npm install || { echo "Backend npm install failed"; exit 1; }

# --- Step 3: Run Database Migrations (if present) ---
echo ""
echo "=============================="
echo "Step 3: Running migrations (if present)"
echo "=============================="
if [ -f "scripts/migrate.js" ]; then
    npm run migrate || { echo "Migration failed"; exit 1; }
else
    echo "⚠️  migrate.js not found, skipping migrations"
fi

# --- Step 4: Seed Database ---
echo ""
echo "=============================="
echo "Step 4: Seeding database"
echo "=============================="
if [ -f "scripts/seedDatabase.js" ]; then
    npm run seed || { echo "Seeding failed"; exit 1; }
else
    echo "⚠️  seedDatabase.js not found, skipping seeding"
fi

# --- Step 5: Start Backend ---
echo ""
echo "=============================="
echo "Step 5: Starting backend server"
echo "=============================="
npm run dev &

# --- Step 6: Install Frontend Dependencies ---
echo ""
echo "=============================="
echo "Step 6: Installing frontend dependencies"
echo "=============================="
cd "../../$FRONTEND_DIR" || exit 1
npm install || { echo "Frontend npm install failed"; exit 1; }

# --- Step 7: Start Frontend ---
echo ""
echo "=============================="
echo "Step 7: Starting React Native frontend"
echo "=============================="
npx react-native start &

echo ""
echo "✅ Full environment setup complete!"
echo "Backend running in background. React Native Metro bundler started."
echo "Use 'npx react-native run-android' or 'npx react-native run-ios' to launch the app."
