#!/bin/bash

set -e

SCRIPT_DIR=$(dirname "$0")
ROOT_DIR="$SCRIPT_DIR/.."

# Generate Terraform secrets
echo "Generating Terraform secrets..."
bash "$SCRIPT_DIR/generate_secrets.sh"

# Convert class schedules to UTC
echo "Convert class schedules to UTC..."
bash "$SCRIPT_DIR/utc_conversion.sh"

# Create Lambda ZIP files
echo "Creating Lambda ZIP files..."
bash "$SCRIPT_DIR/zip_lambda.sh"

# Run Terraform deployment
echo "Running Terraform apply..."
cd "$ROOT_DIR/terraform"
terraform init
terraform apply -auto-approve
cd ..
echo "Deployment completed successfully."
