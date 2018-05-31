#!/bin/bash
set -e

ZT_API_KEY="$1"
ZT_NET="$2"
ZT_IP="$3"

sudo cat << EOF > /etc/apt/sources.list.d/zerotier.list
deb http://download.zerotier.com/debian/xenial xenial main
EOF

sudo curl -fsSL https://www.zerotier.com/misc/contact@zerotier.com.gpg | sudo apt-key add -

sudo apt-get clean -yqq
sudo apt-get update -yqq
sudo apt-get install -yqq \
    zerotier-one

sudo service zerotier-one restart

sudo systemctl enable zerotier-one

# curl -s 'https://pgp.mit.edu/pks/lookup?op=get&search=0x1657198823E52A61' | gpg --import && \
# if z=$(curl -s 'https://install.zerotier.com/' | gpg); then echo "$z" | sudo bash; fi


# echo "Join Zerotier: ${ZT_NET}"
sleep 10
zerotier-cli join ${ZT_NET}
sleep 5
MEMBER_ID=$(zerotier-cli info | awk '{print $3}')

#echo "Configure Zerotier IP: ${ZT_IP}"
cat << EOF | curl -X POST -H "Authorization: Bearer ${ZT_API_KEY}" -d @- "https://my.zerotier.com/api/network/${ZT_NET}/member/${MEMBER_ID}"
{
    "name": "$(hostname)",
    "config": {
        "authorized": true,
        "noAutoAssignIps": true,
        "ipAssignments": ["${ZT_IP}"]
    }
}
EOF