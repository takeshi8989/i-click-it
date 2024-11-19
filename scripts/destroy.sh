#!/bin/bash

set -e

SCRIPT_DIR=$(dirname "$0")
ROOT_DIR="$SCRIPT_DIR/.."

echo "Running Terraform destroy..."
cd "$ROOT_DIR/terraform"
terraform destroy -auto-approve
cd ..

echo "Destroy completed successfully."

echo "Starting cleanup..."
bash "$SCRIPT_DIR/cleanup.sh"
echo "Cleanup completed successfully."