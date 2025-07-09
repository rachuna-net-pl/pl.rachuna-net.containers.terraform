#!/bin/bash
set -eauo pipefail

/opt/scripts/gitlab.bash

exec "$@"