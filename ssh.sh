#!/bin/bash

# --- Step 0: Set variables ---
SSH_KEY="$HOME/.ssh/haloai_id_rsa"
GIT_REMOTE_SSH="$1"  # Pass repo SSH URL as first argument (optional)

# --- Step 1: Fix permissions ---
echo "[*] Fixing SSH permissions..."
chmod 700 ~/.ssh
chmod 600 "$SSH_KEY"
chmod 644 "$SSH_KEY.pub"

# --- Step 2: Start ssh-agent and add key ---
echo "[*] Starting ssh-agent..."
eval "$(ssh-agent -s)"
ssh-add "$SSH_KEY"

# --- Step 3: Configure SSH for GitHub ---
echo "[*] Configuring SSH for GitHub..."
SSH_CONFIG="$HOME/.ssh/config"
if ! grep -q "Host github.com" "$SSH_CONFIG"; then
cat >> "$SSH_CONFIG" <<EOL
Host github.com
    HostName github.com
    User git
    IdentityFile $SSH_KEY
EOL
fi

# --- Step 4: Test SSH connection ---
echo "[*] Testing GitHub SSH connection..."
ssh -T git@github.com

# --- Step 5: Optional: update Git remote ---
if [ ! -z "$GIT_REMOTE_SSH" ]; then
    echo "[*] Updating Git remote to: $GIT_REMOTE_SSH"
    git remote set-url origin "$GIT_REMOTE_SSH"
fi

echo "[*] Done! You should now be able to pull/push via SSH."
