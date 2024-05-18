#!/bin/bash
# Clear terminal
clear

echo -e "\e[36m     _       \e[1m \e[36m _               _              _ \e[1m"
echo -e "\e[36m    | |      \e[1m \e[36m| |             | |            | |\e[1m"
echo -e "\e[36m  __| | ___  \e[1m \e[36m| |__   __ _ ___| |__   ___  __| |\e[1m"
echo -e "\e[36m / _  |/ _ \ \e[1m \e[36m|  _ \ / _  / __|  _ \ / _ \/ _  |\e[1m"
echo -e "\e[36m| (_| |  __/ \e[1m \e[36m| | | | (_| \__ \ | | |  __/ (_| |\e[1m"
echo -e "\e[36m \__,_|\___| \e[1m \e[36m|_| |_|\__,_|___/_| |_|\___|\__,_|\e[1m"
echo ""
echo ""

if ! command -v hashid &> /dev/null || ! command -v hashcat &> /dev/null; then
    echo "Required tools 'hashid' and 'hashcat' are not installed. Please install them."
    exit 1
fi

# Prompt for hashed login
sleep 2
echo -e "\e[36mSubmit the hashed File Location\e[0m"
read input
extension="${input: -4}"
extension_hash=$(echo -n "$extension" | md5sum | awk '{print $1}')
txt_hash=$(echo -n ".txt" | md5sum | awk '{print $1}')
echo -e "Choose your hashtypes: \e[32mall\e[0m | \e[36mMD5\e[0m | \e[35mSHA256\e[0m"
read option
echo ""

hashtypes=()
hashlist=()
found_passwords=()

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
  # Print hash types
  count=0
  for hash_type in "${hashtypes[@]}"; do
    hash_type=$(echo "$hash_type" | awk '{$1=""; print $0}' | awk '{gsub(/[\(\)]/, " "); print}' |  awk '{gsub(/ /, "-"); print substr($0, 2)}')
    if [[ $hash_type = *"'"* ]]; then
      count=$((count+1))
      eval "hash$count=$hash_type" > /dev/null
    fi
    if [[ $hash_type != *"'"* ]]; then
      eval "hashes$count+=($hash_type)" > /dev/null
    fi
  done


dehash() {
  echo -e "\e[36mAnalyzing $3 with $2\e[0m"
  hashcat -a 0 -m $1 $3 ~/Desktop/passwords.txt --quiet 2>/dev/null
  if ! grep -qiF $3 "$potfile"; then
    echo -e "\e[35mNo result.\e[0m"
  else
  echo -e "\e[36mSuccess\e[0m"

  found_passwords+=($(grep $3 -iF "$potfile"))
  echo ""
  fi
  i+=(1)
}

for i in $(seq 1 $count); do
  eval "echo hash$i = \$hash$i" > /dev/null
  eval "echo hashes$i = \${hashes$i[@]}" > /dev/null
  potfile=$(locate potfile)
  for hashtype in $(eval "echo \${hashes$i[@]}"); do
    if grep -q $(eval "echo \$hash$i") "$potfile"; then
      continue
    else
      case $hashtype in
        "MD5")
        if [[ $option == "MD5" ]] || [[ $option == "all" ]]; then
          dehash "0" "MD5" "$(eval "echo \$hash$i")"
	fi
        ;;
        "MD4")
	if [[ $option == "all" ]]; then
          dehash "900" "MD4" "$(eval "echo \$hash$i")"
	fi
        ;;
        "SHA-1")
	if [[ $option == "all" ]]; then
          dehash "100" "sha-1" "$(eval "echo \$hash$i")"
	fi
        ;;
        "SHA-256")
	if [[ $option == "SHA256" ]] || [[ $option == "all" ]]; then
          dehash "1400" "sha-256" "$(eval "echo \$hash$i")"
	fi
        ;;
        "SHA-512")
	if [[ $option == "SHA512" ]] || [[ $option == "all" ]]; then
          dehash "1700" "sha-512" "$(eval "echo \$hash$i")"
	fi
        ;;
        "NTLM")
	if [[ $option == "all" ]]; then
          dehash "1000" "NTLM" "$(eval "echo \$hash$i")"
	fi
        ;;
	"RIPEMD-128")
	if [[ $option == "all" ]]; then
  	  dehash "12000" "Ripemd-128" "$(eval "echo \$hash$i")"
	fi
	;;
	"RIPEMD-256")
	if [[ $option == "all" ]]; then
  	  dehash "8000" "Ripemd-256" "$(eval "echo \$hash$i")"
	fi
	;;
	"Haval-128")
	if [[ $option == "all" ]]; then
	  dehash "8800" "Haval-128" "$(eval "echo \$hash$i")"
	fi
	;;
	"Haval-256")
	if [[ $option == "all" ]]; then
	  dehash "8900" "Haval-256" "$(eval "echo \$hash$i")"
	fi
	;;
	"Double-MD5")
	if [[ $option == "all" ]]; then
	  dehash "2600" "Double-MD5" "$(eval "echo \$hash$i")"
	fi
	;;
      esac
    fi
  done
done
if [ ${#found_passwords[0]} -gt 0 ]; then
  echo ""
  sleep 2
  echo -e "\e[35mPasswords found:\e[0m"
  for password in "${found_passwords[@]}"; do
    echo "$password"
  done
  echo ""
  echo "Find your passwords in: $(locate potfile)"
fi
fi

