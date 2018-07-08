#!/bin/bash
set -e

apt-get update -yqq
apt-get install -yqq curl wget
cat << EOF > /etc/apt/sources.list.d/salt.list
deb http://repo.saltstack.com/apt/ubuntu/16.04/amd64/2018.3 xenial main
EOF

curl -fsSL https://repo.saltstack.com/apt/ubuntu/16.04/amd64/2018.3/SALTSTACK-GPG-KEY.pub | sudo apt-key add -

apt-get clean -yqq
apt-get update -yqq
apt-get install -yqq \
    salt-minion \
    salt-ssh \
    python-boto \
    python-boto3 \
    reclass

systemctl enable salt-minion
systemctl daemon-reload
systemctl restart salt-minion