#!/bin/bash
set -euo pipefail

/opt/scripts/bundle_ca.bash
/opt/scripts/gitlab-ssh.bash


/bin/bash