#!/bin/bash
set -euo pipefail

/opt/scripts/gitlab.bash

exec "$@"