#!/bin/bash
set -e
SCRIPT_DIR=$(dirname "$0")
SOURCE_DIR="$SCRIPT_DIR/../lambda_sources"
OUTPUT_DIR="$SCRIPT_DIR/../lambda_zips"

mkdir -p "$OUTPUT_DIR"
zip -j "$OUTPUT_DIR/lambda_function_start.zip" "$SOURCE_DIR/lambda_function_start.py"
zip -j "$OUTPUT_DIR/lambda_function_stop.zip" "$SOURCE_DIR/lambda_function_stop.py"

echo "Zipped lambda functions to $OUTPUT_DIR"
