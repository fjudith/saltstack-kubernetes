#!/bin/bash
set -e

sudo apt-get clean -yqq
sudo apt-get update -yqq
sudo apt-get install -yqq \
    ufw

ufw --force reset

# Allow VPN
sudo ufw allow in on ${private_interface} to any port ${vpn_port} # vpn on private interface
sudo ufw allow in on ${vpn_interface}

# Disable Logging
sudo ufw logging off

# Allow SSH
sudo ufw allow ssh

# Allow Saltstack
sudo ufw allow 4505
sudo ufw allow 4506

# Allow HTTP and HTTPS
sudo ufw allow http
sudo ufw allow https

# Allow Kubernetes API secure port
sudo ufw allow 6443

# Enable UFW
sudo ufw --force enable

# Display UFW status
sudo ufw status verbose