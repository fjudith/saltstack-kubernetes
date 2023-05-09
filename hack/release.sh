#/bin/bash
set -euo pipefail

source hack/libraries/custom-logger.sh

PUBLIC_DOMAIN=${PUBLIC_DOMAIN:-$(cat srv/pillar/*.sls | grep 'public-domain' | cut -d ' ' -f 2)}

rsync -viva ./srv/salt edge:/srv/
rsync -viva ./srv/pillar edge:/srv/

eok "Published salt pillar and states configuration to Salt-Master."
