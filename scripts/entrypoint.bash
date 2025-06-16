#!/bin/bash
set -euo pipefail

/opt/scripts/bundle_ca.bash

echo -e "\033[1;33m===>\033[0m Przygotowanie kluczy SSH"

if [[ -z "$GITLAB_SSH_KEY" ]]; then
  echo "❌ Błąd: GITLAB_SSH_KEY nie jest ustawione"
  exit 1
fi

/bin/bash