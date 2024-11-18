#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Define script and file paths
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
