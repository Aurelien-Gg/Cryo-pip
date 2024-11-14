#!/bin/bash

# Check if the folder path is provided
if [ -z "$1" ]; then
  echo "Usage: $0 <folder_path>"
  exit 1
fi

# Assign the folder path to a variable
folder_path="$1"

# Ensure the provided path exists
if [ ! -d "$folder_path" ]; then
  echo "Error: Directory '$folder_path' does not exist."
  exit 1
fi

# Create "even" and "odd" directories inside the specified folder if they don't exist
mkdir -p "$folder_path/even" "$folder_path/odd"

# Loop through all .mrc files in the folder
for file in "$folder_path"/faimg-*.mrc; do
  # Extract the number part from the filename (after 'faimg-' and before '.mrc')
  num=$(echo "$file" | sed -e 's/.*faimg-\([0-9]*\)\.mrc/\1/')
  
  # Check if the number is even or odd
  if [ $((num % 2)) -eq 0 ]; then
    mv "$file" "$folder_path/even/"
  else
    mv "$file" "$folder_path/odd/"
  fi
done

echo "Files have been moved to 'even' and 'odd' folders in '$folder_path'."
