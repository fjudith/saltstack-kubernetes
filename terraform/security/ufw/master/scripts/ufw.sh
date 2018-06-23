#!/bin/bash
set -e

sudo apt-get clean -yqq
sudo apt-get update -yqq
sudo apt-get install -yqq \
    ufw

sudo ufw --force reset

# Allow Incoming connection by default
sudo sed -i -r 's/^(DEFAULT_INPUT_POLICY=).*/\1"ACCEPT"/g' /etc/default/ufw

# Allow TCP forwarding
sed -i -r 's|^#(net/ipv4/ip_forward).*|\1=1|g' /etc/ufw/sysctl.conf
sed -i -r 's|^#(net/ipv6/conf/default/forwarding).*|\1=1|g' /etc/ufw/sysctl.conf
sed -i -r 's|^#(net/ipv6/conf/all/forwarding).*|\1=1|g' /etc/ufw/sysctl.conf

sudo ufw default allow FORWARD

# Drop All connection after processing all intermediate rules
sudo sed -i -r 's|^COMMIT|-A ufw-reject-input -j DROP\nCOMMIT|g' /etc/ufw/after.rules

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