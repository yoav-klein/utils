#!/bin/bash

RED="\e[31m"
GREEN="\e[1;32m"
RESET="\e[0m"
set -e

print_header() {
	echo -e "${GREEN}=== $1${RESET}"
}

print_error() {
	echo -e "${RED}### $1${RESET}"
}

if ! [ -f agent-config.json ]; then
	print_error "No agent-config.json file found"
	exit 1
fi

install_dependencies() {
	print_header "Installing dependencies"
	export DEBIAN_FRONTEND=noninteractive
	echo "APT::Get::Assume-Yes \"true\";" | sudo tee /etc/apt/apt.conf.d/90assumeyes
 
	sudo apt-get update
	sudo -E apt-get install -y --no-install-recommends ca-certificates \
		curl \
		jq \
		iputils-ping \
		libcurl4 \
		libicu66 \
		libunwind8 \
		netcat \
		libssl1.0
}

read_configuration() {
	json=$(cat agent-config.json)
	azp_url=$(echo $json | jq -r '.tfs_url')
	azp_collection=$(echo $json | jq -r '.collection')
	azp_pool=$(echo $json | jq -r '.pool')
	azp_user=$(echo $json | jq -r '.user')
	azp_password=$(echo $json | jq -r '.password')
	pat=$(cat pat)

	if [ -z "$azp_url" ] || [ -z "$azp_collection" ] || [ -z "$azp_pool" ] || \
	   [ -z "$azp_user" ] || [ -z "$azp_password" ]; then
	   print_error "agnet-config.sh is invalid"
	   exit 1
	fi
	
}

download_agent() {
	print_header "Downloading agent from server"
	agent_list=$(curl -LsS -u user:$pat "$azp_url/$azp_collection/_apis/distributedtask/packages/agent?platform=linux-x64")
	agent_url=$(echo "$agent_list" | jq -r '.value[0].downloadUrl')
	curl -LsS $agent_url -o agent.tar.gz
	tar -xf agent.tar.gz
}

configure_agent() {
#--auth negotiate \
	  #--userName $username \
	  #--password $password \
	print_header "Configuring agent"
	./config.sh --unattended \
	  --agent AgentDocker1 \
	  --url "$azp_url/$azp_collection" \
	  --pool "$azp_pool" \
	  --auth pat \
	  --token $pat \
	  --work "_work" \
	  --replace \
	  --acceptTeeEula		
}

install_service() {
	sudo ./svc.sh install
	sudo ./svc.sh start
}

install_dependencies
read_configuration
download_agent
configure_agent
#install_service


