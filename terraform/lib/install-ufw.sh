#!/bin/bash
set -e

ZT_NET=$1

apt-get udpate && apt-get install ufw

# Allow Incoming connection by default
sed -i -r 's/^(DEFAULT_INPUT_POLICY=).*/\1"ACCEPT"/g' /etc/default/ufw

# Allow TCP forwarding
sed -i -r 's|^#(net/ipv4/ip_forward).*|\1=1|g' /etc/ufw/sysctl.conf
sed -i -r 's|^#(net/ipv6/conf/default/forwarding).*|\1=1|g' /etc/ufw/sysctl.conf
sed -i -r 's|^#(net/ipv6/conf/all/forwarding).*|\1=1|g' /etc/ufw/sysctl.conf

sudo ufw default allow FORWARD

# Drop All connection after processing all intermediate rules
sed -i -r 's|^COMMIT|-A ufw-reject-input -j DROP\nCOMMIT|g' /etc/ufw/after.rules

# Disable Logging
sudo ufw logging off

# Allow SSH
sudo ufw allow ssh

# Allow Saltstack
sudo ufw allow salt

# Allow HTTPS
sudo ufw allow https

# Enable UFW
sudo ufw --force enable