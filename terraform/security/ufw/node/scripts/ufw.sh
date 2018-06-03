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

# Allow Kubernetes
# sudo ufw allow in on ${kubernetes_interface} # Kubernetes pod overlay interface

# Disable Logging
sudo ufw logging off

# Allow SSH
sudo ufw allow ssh

# Allow Saltstack
sudo ufw allow 4505
sudo ufw allow 4506

# Allow Etcd port
sudo ufw allow 2379
sudo ufw allow 2380

# Enable UFW
sudo ufw --force enable

# Display UFW status
sudo ufw status verbose