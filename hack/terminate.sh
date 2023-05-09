#!/usr/bin/env bash

set -euo pipefail

source hack/libraries/custom-logger.sh

pushd terraform/
terraform destroy -auto-approve
popd 
eok "Provisionned infrastructure."
