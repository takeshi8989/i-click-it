#!/bin/bash

set -e

SCRIPT_DIR=$(dirname "$0")
ROOT_DIR="$SCRIPT_DIR/.."

echo "Convert class schedules to UTC..."
bash "$SCRIPT_DIR/utc_conversion.sh"

echo "Creating Lambda ZIP files..."
bash "$SCRIPT_DIR/zip_lambda.sh"

echo "Running Terraform apply..."
cd "$ROOT_DIR/terraform"
terraform init
terraform apply -auto-approve

echo "Deployment completed successfully."
