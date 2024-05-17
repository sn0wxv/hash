#!/bin/bash

# Clear terminal
clear

# Prompt for hashed login
echo "Submit the hashed credentials or File Location"
read input
extension="${input: -4}"
extension_hash=$(echo -n "$extension" | md5sum | awk '{print $1}')
txt_hash=$(echo -n ".txt" | md5sum | awk '{print $1}')

hashtypes=()
hashlist=()

if [[ $extension_hash  == $txt_hash ]]; then
  # Read contents from file into array
  while IFS= read -r credential; do
    # Analyze each hash
    hashid_output=$(hashid "$credential" 2>/dev/null)
    while IFS= read -r hash_type; do
      hashtypes+=("$hash_type")
    done <<< "$hashid_output"
  done < "$input"

  # Print hash types
  echo "Hash types found:"
  for hash_type in "${hashtypes[@]}"; do
    hash_type=$(echo "$hash_type" | awk '{$1=""; print $0}')
    echo $hash_type
    if [[ $hash_type = "RAdmin v2.x" ]]; then
      echo "hello"
      exit
    fi
  done
fi
