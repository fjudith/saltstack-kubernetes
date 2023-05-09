#!/usr/bin/env bash

set -euo pipefail

source hack/libraries/custom-logger.sh

PUBLIC_DOMAIN=${PUBLIC_DOMAIN:-$(cat srv/pillar/*.sls | grep 'public-domain' | cut -d ' ' -f 2)}

scp master01:/etc/kubernetes/admin.conf ~/.kube/config

public-domain: testruction.io