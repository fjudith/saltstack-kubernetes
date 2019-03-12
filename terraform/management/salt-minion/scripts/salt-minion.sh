#!/bin/bash
set -e

apt-get update -yqq && apt-get install -yqq curl wget

cat << EOF > /etc/apt/sources.list.d/saltstack.list
deb http://repo.saltstack.com/apt/ubuntu/18.04/amd64/2019.2 bionic main
EOF

curl -fsSL https://repo.saltstack.com/apt/ubuntu/18.04/amd64/2019.2/SALTSTACK-GPG-KEY.pub | sudo apt-key add -

apt-get clean -yqq
apt-get update -yqq
apt-get install -yqq \
    salt-minion \
    salt-ssh \
    python-boto \
    python-boto3 \
    python-pyinotify \
    python-psutil \    
    reclass

systemctl enable salt-minion

systemctl daemon-reload

systemctl restart salt-minion
