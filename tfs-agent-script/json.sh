#!/bin/bash

print_error() {
	RED="\e[31m"
	RESET="\e[0m"
	
	echo -e "${RED}### $1${RESET}"
}

if ! [ -f agent-config.json ]; then
	print_error "No agent-config.json file found"
	exit 1
fi

json=$(cat agent-config.json)
azp_url=$(echo $json | jq -r '.tfs_url')
azp_collection=$(echo $json | jq -r '.collection')
azp_pool=$(echo $json | jq -r '.pool')
azp_user=$(echo $json | jq -r '.user')
azp_password=$(echo $json | jq -r '.password')

if [ -z "$azp_url" ] || [ -z "$azp_collection" ] || [ -z "$azp_pool" ] || \
   [ -z "$azp_user" ] || [ -z "$azp_password" ]; then
   print_error "agnet-config.sh is invalid"
fi


