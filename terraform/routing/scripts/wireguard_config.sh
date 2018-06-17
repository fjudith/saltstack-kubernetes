#!/bin/bash
set -e

sed -i -r "s|^(AllowedIps\s\=\s${gateway}\/32)|\1,0.0.0.0/1,128.0.0.0/1|g" /etc/wireguard/${vpn_interface}.conf

systemctl restart wg-quick@${vpn_interface}
