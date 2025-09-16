
#!/bin/bash

# Superstar Podcast Hub - Environment Setup Script
# This script copies .env.example to .env and lets you fill in credentials

ENV_FILE=".env"
EXAMPLE_FILE=".env.example"

# Check if .env.example exists
if [ ! -f "$EXAMPLE_FILE" ]; then
    echo "Error: $EXAMPLE_FILE not found!"
    exit 1
fi

# Copy .env.example to .env if .env doesn't exist
if [ -f "$ENV_FILE" ]; then
    echo "$ENV_FILE already exists. Backing up to .env.bak"
    cp "$ENV_FILE" ".env.bak"
fi

cp "$EXAMPLE_FILE" "$ENV_FILE"
echo "Created $ENV_FILE from $EXAMPLE_FILE"

# Function to replace placeholder values in .env
update_env_var() {
    VAR_NAME=$1
    PROMPT_TEXT=$2
    CURRENT_VALUE=$(grep "^$VAR_NAME=" "$ENV_FILE" | cut -d '=' -f2-)
    
    read -p "$PROMPT_TEXT [$CURRENT_VALUE]: " NEW_VALUE
    if [ -n "$NEW_VALUE" ]; then
        # Escape slashes for sed
        NEW_VALUE_ESCAPED=$(echo "$NEW_VALUE" | sed 's/[\/&]/\\&/g')
        sed -i "s/^$VAR_NAME=.*/$VAR_NAME=$NEW_VALUE_ESCAPED/" "$ENV_FILE"
    fi
}

echo "Fill in the required environment variables:"

update_env_var "MONGODB_URI" "MongoDB Connection URI"
update_env_var "JWT_SECRET" "JWT Secret Key"
update_env_var "CLOUDINARY_CLOUD_NAME" "Cloudinary Cloud Name"
update_env_var "CLOUDINARY_API_KEY" "Cloudinary API Key"
update_env_var "CLOUDINARY_API_SECRET" "Cloudinary API Secret"
update_env_var "AWS_ACCESS_KEY_ID" "AWS Access Key ID"
update_env_var "AWS_SECRET_ACCESS_KEY" "AWS Secret Access Key"
update_env_var "STRIPE_SECRET_KEY" "Stripe Secret Key"
update_env_var "TWILIO_ACCOUNT_SID" "Twilio Account SID"
update_env_var "TWILIO_AUTH_TOKEN" "Twilio Auth Token"
update_env_var "EMAIL_HOST" "SMTP Host"
update_env_var "EMAIL_PORT" "SMTP Port"
update_env_var "EMAIL_USER" "SMTP Username"
update_env_var "EMAIL_PASS" "SMTP Password"

echo ".env setup complete!"
