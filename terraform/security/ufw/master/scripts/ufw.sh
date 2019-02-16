#!/bin/bash
set -e

sudo apt-get clean -yqq
sudo apt-get update -yqq
sudo apt-get install -yqq \
    ufw

sudo ufw --force reset

# Allow TCP forwarding
sudo sed -i -r 's|^#(net/ipv4/ip_forward).*|\1=1|g' /etc/ufw/sysctl.conf
sudo sed -i -r 's|^#(net/ipv6/conf/default/forwarding).*|\1=1|g' /etc/ufw/sysctl.conf
sudo sed -i -r 's|^#(net/ipv6/conf/all/forwarding).*|\1=1|g' /etc/ufw/sysctl.conf

sudo ufw default allow FORWARD

# Enable vpn routing to internet
sudo cat << EOF | tee -a /etc/ufw/before.rules
*nat
:POSTROUTING ACCEPT [0:0]
-A POSTROUTING -s ${overlay_cidr} ! -d ${overlay_cidr} -j MASQUERADE
COMMIT
EOF

# Drop All connection after processing all intermediate rules
sudo sed -i -r 's|^COMMIT|-A ufw-reject-input -j DROP\nCOMMIT|g' /etc/ufw/after.rules

# Allow VPN
sudo ufw allow in on ${private_interface} to any port ${vpn_port} # vpn on private interface
sudo ufw allow in on ${vpn_interface}

# Kubernetes API secure remote port
ufw allow in on ${vpn_interface} kube-apiserver

# Disable Logging
sudo ufw logging off

# Allow SSH
sudo ufw allow ssh

# Allow Saltstack
sudo ufw allow salt in on ${vpn_interface}

# Allow Etcd port
sudo ufw allow in on ${vpn_interface} etcd 
sudo ufw allow in on ${vpn_interface} etcd-peer 

# Allow Flannel / Canal
sudo ufw allow in flannel-vxlan

# Allow Calico
sudo ufw allow in calico-bgp
# ufw allow in calico-typha-agent

# Allow Weave Net
sudo ufw allow in weave
# ufw allow in weave-metrics

# Allow Cilium
sudo ufw allow in cilium-vxlan
sudo ufw allow in cillium-geneve
# ufw allow in cillium-health

# Deny Incoming connection by default
sudo ufw default deny incoming

# Enable UFW
sudo ufw --force enable

# Display UFW status
sudo ufw status verbose