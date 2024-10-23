#!/bin/bash

# ============================================
# Script: process_alignframes.sh
# Description: Processes a specified directory by
#              checking for required files and
#              running the alignframes command.
# Usage: ./process_alignframes.sh -input <inputfile> -output <outputfile> -name <name>
# ============================================

# Exit immediately if a command exits with a non-zero status
set -e

if [ $# -eq 0 ]; then
  echo "No arguments provided."
  exit 1
fi

# Initialize variables
TARGET_DIR=""
FOLDER_NAME=""

while [[ $# -gt 0 ]]; do
  key="$1"
  case $key in
    -input)
      TARGET_DIR="$2"
      shift # past argument
      shift # past value
      ;;
    -output)
      OUTPUT_DIR="$2"
      shift
      shift
      ;;
    -name)
      FOLDER_NAME="$2"
      shift
      shift
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
done

ORIGINAL_DIR=$(pwd)

# Verify that the provided argument is a directory
if [ ! -d "$TARGET_DIR" ]; then
    echo "Error: '$TARGET_DIR' is not a directory."
    exit 1
fi

# Initialize log file
LOG_FILE="process_alignframes_log.txt"
LOG_ALL="$ORIGINAL_DIR/process_alignframes_log.txt"

echo "=============================" > "$LOG_FILE"
echo "Log entry made on: $(date)" >> "$LOG_FILE"
echo "Processing directory: $TARGET_DIR" >> "$LOG_FILE"
echo "=============================" >> "$LOG_FILE"

# Function to log messages
log() {
    echo "$1" >> "$ORIGINAL_DIR/process_alignframes_log.txt"
}

# Check for .tiff files
tiff_files=("$TARGET_DIR"/*.{tiff,tif})
if [ ${#tiff_files[@]} -eq 0 ]; then
    log "No .tiff files found in '$TARGET_DIR'. Exiting."
    echo "No .tiff files found. Check the log for details."
    exit 1
else
    log "Found ${#tiff_files[@]} .tiff files."
fi

# Check for gain_flipx.dm4
gain_file=("$TARGET_DIR"/*.dm4)
if [ ! -f "$gain_file" ]; then
    log "'.dm4' not found in '$TARGET_DIR'. Exiting."
    echo "'.dm4' not found. Check the log for details."
    exit 1
else
    log "Found gain_flipx.dm4."
fi

# Check for .mdoc file
mdoc_files=("$TARGET_DIR"/*.mdoc)
if [ ${#mdoc_files[@]} -eq 0 ]; then
    log "No .mdoc file found in '$TARGET_DIR'. Exiting."
    echo "No .mdoc file found. Check the log for details."
    exit 1
else
    # Use the first .mdoc file found
    mdoc_file="${mdoc_files[0]}"
    log "Found mdoc file: $mdoc_file"
fi

# Create IMOD folder
imod_folder="$OUTPUT_DIR/$FOLDER_NAME"
if [ ! -d "$imod_folder" ]; then
    mkdir "$imod_folder"
    log "Created IMOD folder at '$imod_folder'."
else
    log "IMOD folder already exists at '$imod_folder'."
    exit 1
fi

# Change to the target directory
cd "$TARGET_DIR"

# Construct the alignframes command
# Adjust the command below based on your specific requirements and environment
mdoc_name=$(basename "$mdoc_file")
gain_name=$(basename "$gain_file")
align_command="alignframes -mdoc $mdoc_name -output $imod_folder/stack_AF.mrc -adjust -binning 8,2 -gain $gain_name -pi 1.35 -debug 10000"

log "Running alignframes command: $align_command"

# Execute the alignframes command and log output
if $align_command >> "$LOG_ALL" 2>&1; then
    log "alignframes command completed successfully."
    echo "alignframes completed successfully. Check '$LOG_FILE' for details."
else
    log "alignframes command failed. Check the log for details."
    echo "alignframes failed. Check '$LOG_FILE' for details."
    exit 1
fi

cd "$ORIGINAL_DIR"

# Final log entry
log "Processing completed on $(date)."

echo "Processing completed. Check '$LOG_FILE' for details."

exit 0
