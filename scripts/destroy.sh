#!/bin/bash

set -e

SCRIPT_DIR=$(dirname "$0")
ROOT_DIR="$SCRIPT_DIR/.."

echo "Running Terraform destroy..."
cd "$ROOT_DIR/terraform"
terraform destroy -auto-approve

echo "Destroy completed successfully."
