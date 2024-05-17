#!/bin/bash

# Clear terminal
clear

# Prompt for hashed login
echo "Submit the hashed credentials or File Location"
read input
extension="${input: -4}"
extension_hash=$(echo -n $extension | md5sum | awk '{print $1}' )
txt_hash=$(echo -n ".txt" | md5sum | awk '{print $1}')

credentials=()

if [[ $extension_hash  == $txt_hash ]]; then
  # Read contents from file into array
  while IFS= read -r line; do
    credentials+=("$line")
  done < "$input"

  # Print credentials
  for credential in "${credentials[@]}"; do
    hashid_output=$(hashid "$credential" 2>/dev/null)
    while IFS= read -r hash_type; do
      hashtypes+=("$hash_type")
    done < "$hashid_output"
  done
fi

echo "${hashtypes[@]}"

