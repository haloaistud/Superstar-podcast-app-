#!/bin/bash

# Superstar Podcast Hub - Full Environment Setup Script
# This script sets up environment variables, installs dependencies,
# runs migrations & seeds, and starts backend + frontend.

# --- Config ---
BACKEND_DIR="src/backend"
FRONTEND_DIR="src/frontend"

# --- Helper Functions ---

# Run a command and exit on failure
run_or_exit() {
    "$@"
    if [ $? -ne 0 ]; then
        echo "❌ Command failed: $*"
        exit 1
    fi
}

# --- Step 1: Setup .env ---
echo "=============================="
echo "Step 1: Setting up .env file"
echo "=============================="

# Check if setup_env.sh exists
if [ ! -f "./setup_env.sh" ]; then
    echo "Error: setup_env.sh not found! Make sure it exists in project root."
    exit 1
fi

# Run environment setup script
bash ./setup_env.sh
if [ $? -ne 0 ]; then
    echo "❌ .env setup failed"
    exit 1
fi

# --- Step 2: Install Backend Dependencies ---
echo ""
echo "=============================="
echo "Step 2: Installing backend dependencies"
echo "=============================="
cd "$BACKEND_DIR" || exit 1
run_or_exit npm install

# --- Step 3: Run Database Migrations & Seed ---
echo ""
echo "=============================="
echo "Step 3: Running migrations and seeding database"
echo "=============================="
run_or_exit npm run migrate
run_or_exit npm run seed

# --- Step 4: Start Backend ---
echo ""
echo "=============================="
echo "Step 4: Starting backend server"
echo "=============================="
# Start backend in a new terminal window (for Unix/Linux/macOS)
if command -v gnome-terminal >/dev/null 2>&1; then
    gnome-terminal -- bash -c "npm run dev; exec bash"
elif command -v xterm >/dev/null 2>&1; then
    xterm -e "npm run dev" &
else
    echo "Starting backend in current terminal..."
    npm run dev &
fi

# --- Step 5: Install Frontend Dependencies ---
echo ""
echo "=============================="
echo "Step 5: Installing frontend dependencies"
echo "=============================="
cd "../../$FRONTEND_DIR" || exit 1
run_or_exit npm install

# --- Step 6: Start Frontend (React Native) ---
echo ""
echo "=============================="
echo "Step 6: Starting React Native frontend"
echo "=============================="
# Start metro bundler
npx react-native start &

echo ""
echo "✅ Full environment setup complete!"
echo "Backend running in separate process. React Native Metro bundler started."
echo "You can now open a simulator or device and run:"
echo "  npx react-native run-android  # for Android"
echo "  npx react-native run-ios      # for iOS"
