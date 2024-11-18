#!/bin/bash

set -e

SCRIPT_DIR=$(dirname "$0")
LAMBDA_ZIPS_DIR="$SCRIPT_DIR/../lambda_zips"

echo "Creating Lambda ZIP files..."
bash "$SCRIPT_DIR/zip_lambda.sh"

echo "Running Terraform apply..."
cd "$SCRIPT_DIR/../terraform"
terraform apply -auto-approve

echo "Deployment completed successfully."
