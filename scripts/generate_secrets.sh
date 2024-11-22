#!/bin/bash

set -e

# Define paths
SCRIPT_DIR=$(dirname "$0")
ROOT_DIR="$SCRIPT_DIR/.."
CREDENTIALS_FILE="$ROOT_DIR/user_credentials.json"
TFVARS_FILE="$ROOT_DIR/terraform/secrets.auto.tfvars"

# Check if the credentials file exists
if [[ ! -f "$CREDENTIALS_FILE" ]]; then
  echo "Error: User credentials file ($CREDENTIALS_FILE) not found!"
  echo "Please create the file with the format:"
  echo '{
    "email": "user@example.com",
    "password": "userpassword"
  }'
  exit 1
fi

# Read the JSON file and extract email and password
email=$(jq -r '.email' "$CREDENTIALS_FILE")
password=$(jq -r '.password' "$CREDENTIALS_FILE")

# Validate email and password
if [[ -z "$email" || -z "$password" ]]; then
  echo "Error: Both email and password must be provided in $CREDENTIALS_FILE"
  exit 1
fi

# Exit if email and password are still default values
if [[ "$email" == "user@example.com" && "$password" == "userpassword" ]]; then
  echo "Error: Default email and password detected in $CREDENTIALS_FILE. Please update them."
  echo "For more information, refer to the README: https://github.com/takeshi8989/i-click-it?tab=readme-ov-file#step-3-edit-user-credentials"
  exit 1
fi

# Generate the secrets.auto.tfvars file
cat > "$TFVARS_FILE" <<EOF
iclicker_email = "$email"
iclicker_password = "$password"
EOF

echo "Generated $TFVARS_FILE successfully."
