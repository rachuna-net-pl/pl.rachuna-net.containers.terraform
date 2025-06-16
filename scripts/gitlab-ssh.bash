#!/bin/bash

echo -e "\033[1;33m===>\033[0m Przygotowanie kluczy SSH"

if [[ -z "$GITLAB_SSH_KEY" ]]; then
  echo "❌ Błąd: GITLAB_SSH_KEY nie jest ustawione"
  exit 1
fi

mkdir -p /root/.ssh
chmod 700 /root/.ssh
echo "$GITLAB_SSH_KEY" > /root/.ssh/id_rsa
chmod 600 /root/.ssh/id_rsa

echo "Host gitlab.com IdentityFile /root/.ssh/id_rsa StrictHostKeyChecking no" > /root/.ssh/config
ssh-keyscan gitlab.com >> ~/.ssh/known_hosts

echo "✅ Klucze SSH zostały pomyślnie skonfigurowane."