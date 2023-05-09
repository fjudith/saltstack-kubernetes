#!/usr/bin/env bash

set -euo pipefail

source hack/libraries/custom-logger.sh

pushd terraform/
terraform init
terraform plan
terraform apply -auto-approve
popd 
eok "Provisionned infrastructure."
