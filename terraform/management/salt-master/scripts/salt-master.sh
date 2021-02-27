#!/bin/bash
set -e

export SALT_VERSION=3002.5
export SALTGUI_VERSION=1.23.0
export DEBIAN_FRONTEND=noninteractive
export SALT_USER=salt

sudo apt-get update -yqq && \
sudo apt-get install -yqq --no-install-recommends curl net-tools gnupg2  && \
sudo curl -fsSL http://https://repo.saltproject.io/py3/ubuntu/20.04/amd64/archive/${SALT_VERSION}/SALTSTACK-GPG-KEY.pub | sudo apt-key add - && \
sudo echo "deb http://https://repo.saltproject.io/py3/ubuntu/20.04/amd64/archive/${SALT_VERSION} focal main" | tee -a /etc/apt/sources.list.d/saltstack.list && \
sudo echo "install salt-master and salt-api, dependencies" && \
sudo apt-get update -yqq && \
sudo apt-get install --no-install-recommends -yq \
  lsb-release \
  debconf-utils \
  dmidecode \
  python3-augeas \
  python3-boto \
  python3-boto3 \
  python3-botocore \
  python3-cherrypy3 \
  python3-croniter \
  python3-git \
  python3-pip \
  python3-setuptools \
  python3-netaddr \
  python3-pyinotify \
  python3-ws4py \
  salt-master=${SALT_VERSION}* \
  salt-minion=${SALT_VERSION}* \
  salt-ssh=${SALT_VERSION}* \
  salt-syndic=${SALT_VERSION}* \
  salt-cloud=${SALT_VERSION}* \
  salt-api=${SALT_VERSION}* \
  reclass


echo "add a user for the frontend ${SALT_USER}:${SALT_USER}"
if sudo getent passwd ${SALT_USER} > /dev/null 2>&1; then 
  echo "user \"${SALT_USER}\" already exists" ; 
else 
  sudo useradd -m -s/bin/bash -p $(openssl passwd -1 ${SALT_USER}) ${SALT_USER}
fi

sudo cat << EOF > /etc/salt/master.d/saltgui.conf
external_auth:
  pam:
    salt:
      - .*
      - '@runner'
      - '@wheel'
      - '@jobs'
    sysops:
      - .*
      - '@runner'
      - '@wheel'
      - '@jobs'

rest_cherrypy:
    port: 3333
    host: 0.0.0.0
    disable_ssl: true
    app: /srv/saltgui/index.html
    static: /srv/saltgui/static
    static_path: /static
EOF

sudo cd /opt && curl -L https://github.com/erwindon/SaltGUI/archive/${SALTGUI_VERSION}.tar.gz | tar -xvzf - && \
sudo rm -vf /srv/saltgui && \
sudo ln -vfs /opt/SaltGUI-${SALTGUI_VERSION}/saltgui /srv/saltgui && \
sudo systemctl enable salt-master && \
sudo systemctl enable salt-minion && \
sudo systemctl enable salt-api && \
sudo systemctl daemon-reload && \
sudo systemctl restart salt-master && \
sudo systemctl restart salt-minion && \
sudo systemctl restart salt-api