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
sudo sed -i -r 's|^#(net/ipv4/ip_forward).*|\1=1|g' /etc/ufw/sysctl.conf
sudo sed -i -r 's|^#(net/ipv6/conf/default/forwarding).*|\1=1|g' /etc/ufw/sysctl.conf
sudo sed -i -r 's|^#(net/ipv6/conf/all/forwarding).*|\1=1|g' /etc/ufw/sysctl.conf

sudo ufw default allow FORWARD

# Enable vpn routing to internet
sudo cat << EOF | tee -a /etc/ufw/before.rules
*nat
:POSTROUTING ACCEPT [0:0]
-A POSTROUTING -o ${private_interface} -j MASQUERADE
-A POSTROUTING -s ${overlay_cidr} ! -d ${overlay_cidr} -j MASQUERADE
COMMIT
EOF

# Allow VPN
sudo ufw allow in on ${private_interface} to any port ${vpn_port} # vpn on private interface
sudo ufw allow in on ${vpn_interface}

# Allow Kubernetes
sudo ufw allow in on ${kubernetes_interface} # Kubernetes pod overlay interface

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

# Allow Kubernetes API Server
sudo ufw allow 6443

# Allow Tinyproxy
sudo ufw allow 8888

# Allow HAproxy Stats
sudo ufw allow 58080

# Allow Flannel vxlan
ufw allow in 8472/udp

# Deny Incoming connection by default
sudo ufw default deny incoming

# Enable UFW
sudo ufw --force enable

# Display UFW status
sudo ufw status verbose