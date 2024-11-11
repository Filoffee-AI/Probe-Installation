#!/bin/bash

# Update package list and upgrade packages
sudo apt update && sudo apt upgrade -y

# Add the missing MySQL GPG key (replace the key ID with the one in the error)
# sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys B7B3B788A8D3785C

# Alternatively, download the GPG key manually and add it
# wget https://repo.mysql.com/RPM-GPG-KEY-mysql-2022 -O /tmp/RPM-GPG-KEY-mysql
# sudo gpg --dearmor /tmp/RPM-GPG-KEY-mysql
# sudo mv /tmp/RPM-GPG-KEY-mysql /etc/apt/trusted.gpg.d/

# Install necessary packages, including snmpd
sudo apt install -y python3 python3-pip wget lsb-release gnupg git build-essential libssl-dev libffi-dev python3-dev snmp snmpd cron nmap wireguard curl sshpass

# Enable and start the cron service
sudo systemctl enable cron
sudo systemctl start cron

# Restart SNMPD service
sudo systemctl restart snmpd

# Enable SNMPD to start on boot
sudo systemctl enable snmpd
# Install MySQL 8
# wget https://dev.mysql.com/get/mysql-apt-config_0.8.22-1_all.deb
# sudo dpkg -i mysql-apt-config_0.8.22-1_all.deb
sudo apt update
sudo apt install -y mysql-server

# Start MySQL service
sudo systemctl start mysql
sudo systemctl enable mysql


sudo mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH 'mysql_native_password' BY 'GyanFilo@2023'; FLUSH PRIVILEGES;"

# Create a database 'filo_nms'
sudo mysql -u root -p'GyanFilo@2023' -e "CREATE DATABASE filo_nms;"

# Create tables in the 'filo_nms' database
sudo mysql -u root -p'GyanFilo@2023' -D filo_nms -e "
CREATE TABLE fn_edge_devices (
  id INT(10) NOT NULL AUTO_INCREMENT,
  device_id INT(10) NOT NULL,
  cust_id INT(10) NOT NULL,
  location_id INT(10) NOT NULL,
  location_name VARCHAR(255) NULL DEFAULT NULL COLLATE 'utf8mb4_0900_ai_ci',
  device_ip VARCHAR(255) NULL DEFAULT NULL COLLATE 'utf8mb4_0900_ai_ci',
  org_id VARCHAR(255) NULL DEFAULT NULL COLLATE 'utf8mb4_0900_ai_ci',
  host_name VARCHAR(255) NULL DEFAULT NULL COLLATE 'utf8mb4_0900_ai_ci',
  device_public_ip VARCHAR(255) NULL DEFAULT NULL COLLATE 'utf8mb4_0900_ai_ci',
  device_serial VARCHAR(255) NULL DEFAULT NULL COLLATE 'utf8mb4_0900_ai_ci',
  snmp_str VARCHAR(255) NULL DEFAULT NULL COLLATE 'utf8mb4_0900_ai_ci',
  snmp_version TINYINT(3) NULL DEFAULT NULL,
  security_level VARCHAR(255) NULL DEFAULT NULL COLLATE 'utf8mb4_0900_ai_ci',
  auth_type VARCHAR(255) NULL DEFAULT NULL COLLATE 'utf8mb4_0900_ai_ci',
  auth_password VARCHAR(255) NULL DEFAULT NULL COLLATE 'utf8mb4_0900_ai_ci',
  privacy_type VARCHAR(255) NULL DEFAULT NULL COLLATE 'utf8mb4_0900_ai_ci',
  privacy_password VARCHAR(255) NULL DEFAULT NULL COLLATE 'utf8mb4_0900_ai_ci',
  ssh_username VARCHAR(255) NULL DEFAULT NULL COLLATE 'utf8mb4_0900_ai_ci',
  ssh_password VARCHAR(255) NULL DEFAULT NULL COLLATE 'utf8mb4_0900_ai_ci',
  api_key VARCHAR(255) NULL DEFAULT NULL COLLATE 'utf8mb4_0900_ai_ci',
  ssh_port VARCHAR(50) NULL DEFAULT NULL COLLATE 'utf8mb4_0900_ai_ci',
  api_port VARCHAR(50) NULL DEFAULT NULL COLLATE 'utf8mb4_0900_ai_ci',
  vendor VARCHAR(50) NULL DEFAULT NULL COLLATE 'utf8mb4_0900_ai_ci',
  type VARCHAR(50) NULL DEFAULT NULL COLLATE 'utf8mb4_0900_ai_ci',
  ent DATETIME NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id) USING BTREE
);

CREATE TABLE fn_isp_details (
  id INT(10) NOT NULL AUTO_INCREMENT,
  isp_wan_id INT(10) NOT NULL DEFAULT -1,
  edge_device_id INT(10) NOT NULL DEFAULT 0,
  cust_id INT(10) NULL DEFAULT 0,
  location_id INT(10) NULL DEFAULT NULL,
  public_ip VARCHAR(100) NULL DEFAULT NULL COLLATE 'utf8mb4_general_ci',
  private_ip VARCHAR(100) NULL DEFAULT NULL COLLATE 'utf8mb4_general_ci',
  internal_ip VARCHAR(100) NULL DEFAULT NULL COLLATE 'utf8mb4_general_ci',
  vendor_id INT(10) NULL DEFAULT NULL,
  default_gateway VARCHAR(100) NULL DEFAULT NULL COLLATE 'utf8mb4_general_ci',
  firewall_ip VARCHAR(100) NULL DEFAULT NULL COLLATE 'utf8mb4_general_ci',
  link_type VARCHAR(50) NULL DEFAULT NULL COLLATE 'utf8mb4_general_ci',
  if_name VARCHAR(50) NULL DEFAULT NULL COLLATE 'utf8mb4_0900_ai_ci',
  if_index VARCHAR(50) NULL DEFAULT NULL COLLATE 'utf8mb4_0900_ai_ci',
  ent DATETIME NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id) USING BTREE
);

CREATE TABLE fn_latest_in_out_octates (
  id BIGINT(20) UNSIGNED NOT NULL AUTO_INCREMENT,
  isp_wan_id INT(10) UNSIGNED NULL DEFAULT NULL,
  public_ip VARCHAR(50) NULL DEFAULT NULL COLLATE 'utf8mb4_0900_ai_ci',
  device_ip VARCHAR(50) NULL DEFAULT NULL COLLATE 'utf8mb4_0900_ai_ci',
  ifindex SMALLINT(5) NULL DEFAULT NULL,
  in_octates BIGINT(20) UNSIGNED NULL DEFAULT NULL,
  out_octates BIGINT(20) UNSIGNED NULL DEFAULT NULL,
  created_at DATETIME NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id) USING BTREE,
  INDEX public_ip (public_ip) USING BTREE,
  INDEX device_ip (device_ip) USING BTREE,
  INDEX created_at (created_at) USING BTREE,
  INDEX isp_wan_id (isp_wan_id) USING BTREE
);"

# Clone the repository containing MIBs, isp_internal_probe, and snmp.conf from GitHub
GITHUB_USERNAME="leetcodeisalie"   # Replace with your GitHub username
GITHUB_TOKEN="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"   # Replace with your personal access token
GIT_REPO_URL="https://$GITHUB_USERNAME:$GITHUB_TOKEN@github.com/Filoffee-AI/internal_probe_with_wg_for_single_customer.git"  # Replace with actual repository URL

# Clone the GitHub repository
git clone $GIT_REPO_URL /tmp/isp_repo

# Move MIBs to /usr/share/snmp/mibs/
sudo rm -rf /usr/share/snmp/mibs/
sudo mkdir -p /usr/share/snmp/mibs/
sudo mv -f /tmp/isp_repo/mibs/* /usr/share/snmp/mibs/

# Move snmp.conf to /etc/snmp/
sudo rm -rf /etc/snmp/
sudo mkdir -p /etc/snmp/
sudo mv /tmp/isp_repo/snmp.conf /etc/snmp/snmp.conf

# Move isp_internal_probe to /home
sudo rm -rf /home/isp_internal_probe
sudo mv /tmp/isp_repo/isp_internal_probe /home/

# Set correct permissions
sudo chmod -R 755 /usr/share/snmp/mibs/
sudo chmod 644 /etc/snmp/snmp.conf

# Remove the temporary repository
rm -rf /tmp/isp_repo

# Install required Python packages
pip3 install --upgrade pip

pip3 install mysql-connector-python sqlalchemy numpy pandas \
  netmiko paramiko pysnmp easysnmp \
  cryptography keyring keyrings.alt \
  aiohttp aiosignal asttokens async-timeout \
  urllib3 influxdb-client python-nmap


# Clear all existing cron jobs
crontab -r  

# Wireguard setup scripts
cd /home/isp_internal_probe && cp wg0.conf /etc/wireguard
cd /home/isp_internal_probe && chmod +755 wireguard-start.py
cd /home/isp_internal_probe && python3 wireguard-start.py

cd /home/isp_internal_probe && python3 encrypt.py
rm /home/isp_internal_probe/config.json

# Run /home/isp_internal_probe/probe_initial.sh once
# sudo chmod +x /home/isp_internal_probe/probe_intial.sh
cd /home/isp_internal_probe && python3 register_probe.py

# Add cron jobs
(crontab -l 2>/dev/null; echo "*/15 * * * * cd /home/isp_internal_probe && python3 check_config_update_run_probe_initial.py >> /home/isp_internal_probe/logs/inital_logs_\$(date +\%Y\%m\%d).log") | crontab -
(crontab -l 2>/dev/null; echo "*/30 * * * * cd /home/isp_internal_probe && sudo sh probe_intial.sh >> /home/isp_internal_probe/logs/inital_logs_\$(date +\%Y\%m\%d).log") | crontab -
(crontab -l 2>/dev/null; echo "*/10 * * * * cd /home/isp_internal_probe && python3 test_ssh_snmp.py >> /home/isp_internal_probe/logs/test_ssh_snmp_\$(date +\%Y\%m\%d).log") | crontab -
(crontab -l 2>/dev/null; echo "*/30 * * * * cd /home/isp_internal_probe && sudo sh ssh_key_clear.sh") | crontab -
(crontab -l 2>/dev/null; echo "0 */12 * * * cd /home/isp_internal_probe && python3 delete_old_logs.py") | crontab -
(crontab -l 2>/dev/null; echo "* * * * * cd /home/isp_internal_probe && python3 get_octates.py >> /home/isp_internal_probe/logs/utilization_log_\$(date +\%Y\%m\%d).log") | crontab -
(crontab -l 2>/dev/null; echo "* * * * * cd /home/isp_internal_probe && python3 get_push_edge_device_ping_status.py >> /home/isp_internal_probe/logs/ed_ping_status_log_\$(date +\%Y\%m\%d).log") | crontab -
(crontab -l 2>/dev/null; echo "* * * * * cd /home/isp_internal_probe && python3 internal_probe_main_script.py >> /home/isp_internal_probe/logs/polling_logs_\$(date +\%Y\%m\%d).log") | crontab -
(crontab -l 2>/dev/null; echo "* * * * * cd /home/isp_internal_probe && python3 poll_non_meraki_dbb_links.py >> /home/isp_internal_probe/logs/dbb_non_polling_logs_\$(date +\%Y\%m\%d).log") | crontab -
(crontab -l 2>/dev/null; echo "* * * * * cd /home/isp_internal_probe && python3 poll_meraki_dbb_links.py >> /home/isp_internal_probe/logs/dbb_meraki_polling_logs_\$(date +\%Y\%m\%d).log") | crontab -
(crontab -l 2>/dev/null; echo "*/5 * * * * cd /home/isp_internal_probe && python3 check_isp_down_for_cisco.py >> /home/isp_internal_probe/logs/check_link_down_for_cisco_\$(date +\%Y\%m\%d).log") | crontab -

# Display installation status
echo "Installation Complete"
echo "Python Version: $(python3 --version)"
echo "MySQL Version: $(mysql --version)"
