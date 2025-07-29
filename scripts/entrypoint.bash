#!/bin/bash
set -euo pipefail

/opt/scripts/bundle_ca.bash
/opt/scripts/gitlab.bash

if [[ $# -gt 0 ]]; then
  exec "$@"
else
  exec /bin/bash
fi
