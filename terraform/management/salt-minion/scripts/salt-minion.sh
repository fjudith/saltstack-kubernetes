#!/bin/bash
set -e

SALT_VERSION=2019.2.0
DEBIAN_FRONTEND=noninteractive

apt-get update -yqq && \
apt-get install -yqq --no-install-recommends curl net-tools gnupg2  && \
curl -fsSL http://repo.saltstack.com/py3/ubuntu/18.04/amd64/archive/${SALT_VERSION}/SALTSTACK-GPG-KEY.pub | sudo apt-key add - && \
echo "deb http://repo.saltstack.com/py3/ubuntu/18.04/amd64/archive/${SALT_VERSION} bionic main" > /etc/apt/sources.list.d/saltstack.list && \
echo "install salt-master and salt-api, dependencies" && \
apt-get update -yqq && \
apt-get install --install-suggests -yqq \
  python3-pip \
  python3-setuptools \
  python3-cherrypy3 \
  python3-pyinotify \
  python3-ws4py \
  salt-minion=${SALT_VERSION}* \
  salt-ssh=${SALT_VERSION}* \
  reclass && \
echo "add a user for the frontend salt:salt" && \
useradd -m -s/bin/bash -p $(openssl passwd -1 salt) salt && \
systemctl enable salt-minion && \
systemctl daemon-reload && \
systemctl restart salt-minion
