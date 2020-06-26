#!/bin/bash
set -e

export SALT_VERSION=3001
export DEBIAN_FRONTEND=noninteractive
export SALT_USER=salt

apt-get update -yqq && \
apt-get install -yqq --no-install-recommends curl net-tools gnupg2  && \
curl -fsSL http://repo.saltstack.com/py3/ubuntu/20.04/amd64/archive/${SALT_VERSION}/SALTSTACK-GPG-KEY.pub | sudo apt-key add - && \
echo "deb http://repo.saltstack.com/py3/ubuntu/20.04/amd64/archive/${SALT_VERSION} focal main" > /etc/apt/sources.list.d/saltstack.list && \
echo "install salt-master and salt-api, dependencies" && \
apt-get update -yqq && \
apt-get install --no-install-recommends -yq \
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
  salt-minion=${SALT_VERSION}* \
  salt-ssh=${SALT_VERSION}* \
  reclass && \
echo "add a user for the frontend ${SALT_USER}:${SALT_USER}" && \
if getent passwd ${SALT_USER} > /dev/null 2>&1; then 
  echo "user \"${SALT_USER}\" already exists" ; 
else 
  useradd -m -s/bin/bash -p $(openssl passwd -1 ${SALT_USER}) ${SALT_USER}
fi && \
systemctl enable salt-minion && \
systemctl daemon-reload && \
systemctl restart salt-minion