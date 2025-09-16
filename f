#!/bin/bash

# Superstar Podcast Hub - Full Environment Setup Script
# Features: 
# - Automatic .env setup
# - Install dependencies
# - Run migrations & seeds (if present)
# - Start backend & frontend
# - Push initial scaffold to GitHub
# - Robust error handling

# ------------------------
# Config
# ------------------------
BACKEND_DIR="src/backend"
FRONTEND_DIR="src/frontend"
SETUP_ENV_SCRIPT="./setup_env.sh"
GITHUB_USER="haloaistud"
REPO_NAME="Superstar-podcast-app-"
BRANCH_NAME="main"
REMOTE_URL="git@github.com:$GITHUB_USER/$REPO_NAME.git"

# ------------------------
# Helper Functions
# ------------------------
run_or_exit() {
    "$@"
    if [ $? -ne 0 ]; then
        echo "❌ Command failed: $*"
        exit 1
    fi
}

check_file_exists() {
    if [ ! -f "$1" ]; then
        echo "⚠️  File $1 not found"
        return 1
    fi
    return 0
}

# ------------------------
# Step 0: Create setup_env.sh if missing
# ------------------------
if [ ! -f "$SETUP_ENV_SCRIPT" ]; then
    echo "setup_env.sh not found. Creating automatically..."
    cat > "$SETUP_ENV_SCRIPT" << 'EOF'
#!/bin/bash
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

# ------------------------
# Step 1: Setup .env
# ------------------------
echo "=============================="
echo "Step 1: Setting up .env file"
echo "=============================="
run_or_exit bash "$SETUP_ENV_SCRIPT"

# ------------------------
# Step 2: Install backend dependencies
# ------------------------
echo "=============================="
echo "Step 2: Installing backend dependencies"
echo "=============================="
cd "$BACKEND_DIR" || exit 1
run_or_exit npm install

# ------------------------
# Step 3: Run migrations (if exists)
# ------------------------
echo "=============================="
echo "Step 3: Running migrations (if present)"
echo "=============================="
if check_file_exists "scripts/migrate.js"; then
    run_or_exit npm run migrate
else
    echo "⚠️  migrate.js not found, skipping migrations"
fi

# ------------------------
# Step 4: Seed database (if exists)
# ------------------------
echo "=============================="
echo "Step 4: Seeding database"
echo "=============================="
if check_file_exists "scripts/seedDatabase.js"; then
    run_or_exit npm run seed
else
    echo "⚠️  seedDatabase.js not found, skipping seeding"
fi

# ------------------------
# Step 5: Start backend
# ------------------------
echo "=============================="
echo "Step 5: Starting backend server"
echo "=============================="
npm run dev &

# ------------------------
# Step 6: Install frontend dependencies
# ------------------------
echo "=============================="
echo "Step 6: Installing frontend dependencies"
echo "=============================="
cd "../../$FRONTEND_DIR" || exit 1
run_or_exit npm install

# ------------------------
# Step 7: Start frontend
# ------------------------
echo "=============================="
echo "Step 7: Starting React Native frontend"
echo "=============================="
npx react-native start &

# ------------------------
# Step 8: GitHub Push
# ------------------------
echo "=============================="
echo "Step 8: Pushing initial scaffold to GitHub"
echo "=============================="

cd ../../ || exit 1

# Initialize git if needed
[ ! -d ".git" ] && git init

# Add remote if missing
if ! git remote | grep -q "origin"; then
    git remote add origin "$REMOTE_URL"
fi

# Stage and commit
git add .
git commit -m "Initial scaffold commit" || echo "No changes to commit"

# Push to GitHub
git push -u origin "$BRANCH_NAME" || echo "⚠️ Git push failed. Check your credentials or repo URL."

echo ""
echo "✅ Full setup complete!"
echo "Backend running, React Native bundler started."
echo "Visit https://github.com/$GITHUB_USER/$REPO_NAME to verify push."
echo "Use 'npx react-native run-android' or 'npx react-native run-ios' to launch the app."
