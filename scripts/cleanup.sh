#!/bin/bash

set -e

SCRIPT_DIR=$(dirname "$0")
ROOT_DIR="$SCRIPT_DIR/.."

# Define paths for cleanup
UTC_FILE="$ROOT_DIR/class_schedules_utc.json"
LAMBDA_ZIPS_DIR="$ROOT_DIR/lambda_zips"

echo "Starting cleanup..."

# Remove class_schedules_utc.json
if [[ -f "$UTC_FILE" ]]; then
  echo "Removing $UTC_FILE"
  rm -f "$UTC_FILE"
else
  echo "$UTC_FILE not found, skipping."
fi

# Remove lambda_zips directory
if [[ -d "$LAMBDA_ZIPS_DIR" ]]; then
  echo "Removing $LAMBDA_ZIPS_DIR"
  rm -rf "$LAMBDA_ZIPS_DIR"
else
  echo "$LAMBDA_ZIPS_DIR not found, skipping."
fi

echo "Cleanup completed successfully."
