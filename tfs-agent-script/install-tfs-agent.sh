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

if ! [ -f agent.config ]; then
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
	source agent.config
	
	pat=$(cat pat)

	if [ -z "$AZ_URL" ] || [ -z "$AZ_COLLECTION" ] || [ -z "$AZ_POOL" ] || \
	   [ -z "$AZ_USER" ] || [ -z "$AZ_PASSWORD" ]; then
	   print_error "agnet.config is invalid"
	   exit 1
	fi
	
}

print_line() {
    printf "* %-40s *\n" "$1"
}

print_configuration() {
    echo "***********************************"
    print_line "Configuration"
    print_line ""
    print_line "URL: $AZ_URL"
    print_line "Collection: $AZ_COLLECTION"
    print_line "Pool: $AZ_POOL"
    print_line "User: $AZ_USER"
    print_line ""
    echo "***********************************"
}

download_agent() {
	print_header "Downloading agent from server"
	code=$(curl -LsS -u user:$pat "$AZ_URL/$AZ_COLLECTION/_apis/distributedtask/packages/agent?platform=linux-x64" -o agents.txt -w "%{http_code}")
	if [ "$code" = "401" ] || [ "$code" = "403" ]; then
	    print_error "Unauthorized ! Check your credentials and make sure you have permissions"
	fi
	agent_url=$(cat agents.txt | jq -r '.value[0].downloadUrl')
	curl -LsS $agent_url -o agent.tar.gz
	rm agents.txt
	
	if [ -d agent ]; then
	    rm -rf agent
	fi 
	mkdir agent
	tar -xf agent.tar.gz -C agent
	rm agent.tar.gz
	cd agent
}

configure_agent() {
#--auth negotiate \
	  #--userName $username \
	  #--password $password \
	print_header "Configuring agent"
	./config.sh --unattended \
	  --agent AgentDocker1 \
	  --url "$AZ_URL/$AZ_COLLECTION" \
	  --pool "$AZ_POOL" \
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
install_service


