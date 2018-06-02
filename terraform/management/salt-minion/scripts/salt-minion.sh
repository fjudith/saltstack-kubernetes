#!/bin/bash
set -e

sudo apt-get update -yqq
sudo apt-get install -yqq curl wget
sudo cat << EOF > /etc/apt/sources.list.d/salt.list
deb http://repo.saltstack.com/apt/ubuntu/16.04/amd64/2018.3 xenial main
EOF

sudo curl -fsSL https://repo.saltstack.com/apt/ubuntu/16.04/amd64/2018.3/SALTSTACK-GPG-KEY.pub | sudo apt-key add -

sudo apt-get clean -yqq
sudo apt-get update -yqq
sudo apt-get install -yqq \
    salt-minion \
    salt-ssh \
    reclass


sudo service salt-minion restart
sudo systemctl enable salt-minion