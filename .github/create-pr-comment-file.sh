#!/bin/bash

# Define the maximum size in bytes
MAX_SIZE=10485760  # 10 MB

# Initialize output file counter and base name
OUTPUT_BASE_NAME="combined_file"
output_file_count=1
OUTPUT_FILE="${OUTPUT_BASE_NAME}_${output_file_count}.txt"

# Remove existing files with the same base name to start fresh
rm -f "${OUTPUT_BASE_NAME}_*.txt"

# Current size of the output file
current_size=0

# Loop through all the files passed as arguments to the script
for file in "$@"; do
  if [ -f "$file" ]; then  # Check if the argument is a valid file
    # Get the size of the file to be added
    file_size=$(stat -c %s "$file")

    # Check if adding this file will exceed the limit
    if (( current_size + file_size > MAX_SIZE )); then
      # Start a new output file
      output_file_count=$((output_file_count + 1))
      OUTPUT_FILE="${OUTPUT_BASE_NAME}_${output_file_count}.txt"
      current_size=0  # Reset current size for the new output file

      echo "Reached size limit. Creating new output file: $OUTPUT_FILE."
    fi

    # Concatenate the file to the current output file
    cat "$file" >> "$OUTPUT_FILE"

    # Update the current size
    current_size=$((current_size + file_size))

    echo "Added '$file' to '$OUTPUT_FILE'. Current size: $current_size bytes."
  else
    echo "'$file' is not a valid file. Skipping."
  fi
done

echo "Concatenation completed. Total output files: $output_file_count."
