#!/bin/bash

echo -e "\033[1;33m===>\033[0m Przygotowanie kluczy SSH"

if [[ -z "$GITLAB_SSH_KEY" ]]; then
  echo "⚠️  GITLAB_SSH_KEY nie jest ustawione, spróbuje pobrać"
  if [[ -z "$VAULT_ADDR" ]]; then
    echo "❌  Błąd: VAULT_ADDR nie jest ustawione"
    exit 1
  fi
  if [[ -z "$VAULT_TOKEN" ]]; then
    echo "❌  Błąd: VAULT_TOKEN nie jest ustawione"
    exit 1
  fi
  
  export GITLAB_SSH_KEY=$(curl -s -k -H "X-Vault-Token: $VAULT_TOKEN" $VAULT_ADDR/v1/kv-gitlab/data/pl.rachuna-net/auth/gitlab | jq -r .data.data.GITLAB_SSH_KEY)
  echo "🔑  Pobrano sekret z Vaulta"
fi

if [[ -z "$GITLAB_TOKEN" ]]; then
  echo "⚠️  GITLAB_TOKEN nie jest ustawione, spróbuje pobrać"
  if [[ -z "$VAULT_ADDR" ]]; then
    echo "❌  Błąd: VAULT_ADDR nie jest ustawione"
    exit 1
  fi
  if [[ -z "$VAULT_TOKEN" ]]; then
    echo "❌  Błąd: VAULT_TOKEN nie jest ustawione"
    exit 1
  fi

  export GITLAB_TOKEN=$(curl -s -k -H "X-Vault-Token: $VAULT_TOKEN" $VAULT_ADDR/v1/kv-gitlab/data/pl.rachuna-net/auth/gitlab | jq -r .data.data.GITLAB_TOKEN)
  echo "🔑  Pobrano sekret z Vaulta"
fi

mkdir -p $HOME/.ssh
chmod 700 $HOME/.ssh
echo "$GITLAB_SSH_KEY" > $HOME/.ssh/id_rsa
chmod 600 $HOME/.ssh/id_rsa

echo "Host gitlab.com IdentityFile $HOME/.ssh/id_rsa StrictHostKeyChecking no" > $HOME/.ssh/config
ssh-keyscan gitlab.com >> $HOME/.ssh/known_hosts

echo "✅  Klucze SSH zostały pomyślnie skonfigurowane."