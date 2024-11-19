#!/bin/bash

sudo apt update && sudo apt upgrade -y
sudo apt-get install -y curl jq

GITHUB_USERNAME="GouravTerwadkar" 
GITHUB_TOKEN="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"  
GIT_REPO_URL="https://$GITHUB_USERNAME:$GITHUB_TOKEN@github.com/Filoffee-AI/Basestation-DC-Agent-V1.1.git"  
GIT_MIB_REPO_URL="https://$GITHUB_USERNAME:$GITHUB_TOKEN@github.com/Filoffee-AI/Filo-MIBS.git"

git clone $GIT_REPO_URL /home/Basestation-DC-Agent-V1.1
git clone $GIT_MIB_REPO_URL /home/Filo-MIBS

sudo rm -rf /usr/share/snmp/mibs/
sudo mkdir -p /usr/share/snmp/mibs/
sudo cp -r /home/Filo-MIBS/mibs/* /usr/share/snmp/mibs/

cd /home/Basestation-DC-Agent-V1.1

sudo git fetch
sudo git switch feature/Installation
sudo bash /home/Basestation-DC-Agent-V1.1/install.sh
