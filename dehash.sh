#!/bin/bash

# Clear terminal
clear

# Prompt for hashed login
echo "Submit the hashed credentials or File Location"
input="/home/aki/Desktop/test.txt"
extension="${input: -4}"
extension_hash=$(echo -n "$extension" | md5sum | awk '{print $1}')
txt_hash=$(echo -n ".txt" | md5sum | awk '{print $1}')

hashtypes=()
hashlist=()

if [[ $extension_hash  == $txt_hash ]]; then
  # Read contents from file into array
  while IFS= read -r credential; do
    hashed_logins+=($credential)
    # Analyze each hash
    hashid_output=$(hashid "$credential" 2>/dev/null)
    # Increment counter
    counter=$((counter+1))
    # Save hashid_output to a variable
    hash_output_variable="hash_output_$counter"
    declare "$hash_output_variable"="$hashid_output"
    while IFS= read -r hash_type; do
      hashtypes+=("$hash_type")
    done <<< "$hashid_output"
  done < "$input"

  hashes1=()
  hashes2=()
  hashes3=()
  # Print hash types
  echo "hashes:"
  count=0
  for hash_type in "${hashtypes[@]}"; do
    hash_type=$(echo "$hash_type" | awk '{$1=""; print $0}' | awk '{gsub(/ /, "-"); print substr($0, 2)}')
    if [[ $hash_type = *"'"* ]]; then
      count=$((count+1))
    fi
    if [ $count -eq 1 ]; then
      if [[ $hash_type != *"'"* ]]; then
        hashes1+=($hash_type)
      else
        echo $hash_type
      fi
    elif [ $count -eq 2 ]; then
      if [[ $hash_type != *"'"* ]]; then
        hashes2+=($hash_type)
      else
        echo $hash_type
      fi
    elif [ $count -eq 3 ]; then
      if [[ $hash_type != *"'"* ]]; then
        hashes3+=($hash_type)
      else
        echo $hash_type
      fi
    fi
  done
fi
#echo "${hashes3[@]}"
#echo "${hashes2[@]}"
#echo "${hashes1[@]}"
for hsh in "${hashes1[@]}"; do
  if [[ $hsh == "MD5" ]]; then
    hashcat -a 0 -m 0 /home/aki/Desktop/test.txt  ~/Desktop/rockyou.txt --quiet
    potfile=$(locate potfile)
    # if hashed md5 is not in potfile, say *couldnt find password*
  fi
done



# this is a test

