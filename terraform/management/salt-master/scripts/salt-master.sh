#!/bin/bash
set -e

export SALT_VERSION=2019.2.0
export SALTGUI_VERSION=1.16.0
export DEBIAN_FRONTEND=noninteractive
export SALT_USER=salt

apt-get update -yqq && \
apt-get install -yqq --no-install-recommends curl net-tools gnupg2  && \
curl -fsSL http://repo.saltstack.com/py3/ubuntu/18.04/amd64/archive/${SALT_VERSION}/SALTSTACK-GPG-KEY.pub | sudo apt-key add - && \
echo "deb http://repo.saltstack.com/py3/ubuntu/18.04/amd64/archive/${SALT_VERSION} bionic main" | tee -a /etc/apt/sources.list.d/saltstack.list && \
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
  python3-ioflo \
  python3-raet \
  python3-setuptools \
  python3-timelib \
  python3-netaddr \
  python3-pyinotify \
  python3-ws4py \
  salt-master=${SALT_VERSION}* \
  salt-minion=${SALT_VERSION}* \
  salt-ssh=${SALT_VERSION}* \
  salt-syndic=${SALT_VERSION}* \
  salt-cloud=${SALT_VERSION}* \
  salt-api=${SALT_VERSION}* \
  reclass && \
echo "add a user for the frontend ${SALT_USER}:${SALT_USER}" && \
if getent passwd ${SALT_USER} > /dev/null 2>&1; then 
  echo "user \"${SALT_USER}\" already exists" ; 
else 
  useradd -m -s/bin/bash -p $(openssl passwd -1 ${SALT_USER}) ${SALT_USER}
fi

cat << EOF > /etc/salt/master.d/saltgui.conf
external_auth:
  pam:
    salt:
      - .*
      - '@runner'
      - '@wheel'
      - '@jobs'

rest_cherrypy:
    port: 3333
    host: 0.0.0.0
    disable_ssl: true
    app: /srv/saltgui/index.html
    static: /saltgui/static
    static_path: /static
EOF

cd /opt && curl -L https://github.com/erwindon/SaltGUI/archive/${SALTGUI_VERSION}.tar.gz | tar -xvzf - && \
ln -fs /opt/SaltGUI-${SALTGUI_VERSION} /srv/saltgui && \
systemctl enable salt-master && \
systemctl enable salt-minion && \
systemctl enable salt-api && \
systemctl daemon-reload && \
systemctl restart salt-master && \
systemctl restart salt-minion && \
systemctl restart salt-api
