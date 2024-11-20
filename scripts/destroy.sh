#!/bin/bash

set -e

# Define paths
SCRIPT_DIR=$(dirname "$0")
ROOT_DIR="$SCRIPT_DIR/.."

# Run Terraform destroy
echo "Running Terraform destroy..."
cd "$ROOT_DIR/terraform"
terraform destroy -auto-approve
cd ..

echo "Destroy completed successfully."

# Cleanup generated files
echo "Starting cleanup..."
bash "$SCRIPT_DIR/cleanup.sh"
