#!/bin/bash

sudo apt update && sudo apt upgrade -y
sudo apt-get install -y curl jq qemu

read -sp "Enter your ACcess token: " GITHUB_TOKEN
echo

# Define GitHub username and repository URLs
GITHUB_USERNAME="GouravTerwadkar"
GIT_REPO_URL="https://$GITHUB_USERNAME:$GITHUB_TOKEN@github.com/Filoffee-AI/Basestation-DC-Agent-V1.1.git"
GIT_MIB_REPO_URL="https://$GITHUB_USERNAME:$GITHUB_TOKEN@github.com/Filoffee-AI/Filo-MIBS.git"

# Print a message to indicate success (Token is not displayed)
echo "GitHub token received and repositories are ready to be cloned."

git clone $GIT_REPO_URL /home/Basestation-DC-Agent-V1.1
git clone $GIT_MIB_REPO_URL /home/Filo-MIBS

sudo rm -rf /usr/share/snmp/mibs/
sudo mkdir -p /usr/share/snmp/mibs/
sudo cp -r /home/Filo-MIBS/mibs/* /usr/share/snmp/mibs/

cd /home/Basestation-DC-Agent-V1.1

sudo git fetch
sudo git switch feature/Installation
sudo bash /home/Basestation-DC-Agent-V1.1/install.sh
sudo bash /home/Basestation-DC-Agent-V1.1/install_script.sh
