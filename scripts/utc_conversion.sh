#!/bin/bash

set -e

# Define paths
SCRIPT_DIR=$(dirname "$0")
ROOT_DIR="$SCRIPT_DIR/.."

PYTHON_SCRIPT="$SCRIPT_DIR/convert_to_utc.py"
INPUT_FILE="$ROOT_DIR/class_schedules.json"
OUTPUT_FILE="$ROOT_DIR/class_schedules_utc.json"

# Check if Python script exists
if [[ ! -f "$PYTHON_SCRIPT" ]]; then
  echo "Error: Python script $PYTHON_SCRIPT not found!"
  exit 1
fi

# Check if input file exists
if [[ ! -f "$INPUT_FILE" ]]; then
  echo "Error: Input file $INPUT_FILE not found!"
  exit 1
fi

# Validate JSON and exit if it contains placeholders or invalid JSON
if ! jq empty "$INPUT_FILE" 2>/dev/null; then
  echo "Error: Input file $INPUT_FILE contains invalid JSON or comments!"
  exit 1
fi

# Check for placeholder values in the JSON
if jq -e '.[] | select(.classname == "")' "$INPUT_FILE" >/dev/null; then
  echo "Error: Input file $INPUT_FILE contains placeholders. Please update the file with actual data."
  echo "For more information, refer to the README: https://github.com/takeshi8989/i-click-it?tab=readme-ov-file#step-4-edit-class-schedules"
  exit 1
fi

# Run the Python script
echo "Running Python script to convert class schedules to UTC..."
python3 "$PYTHON_SCRIPT"

# Check if the output file was created
if [[ -f "$OUTPUT_FILE" ]]; then
  echo "Conversion successful! Output file: $OUTPUT_FILE"
else
  echo "Error: Conversion failed. Output file not created."
  exit 1
fi
