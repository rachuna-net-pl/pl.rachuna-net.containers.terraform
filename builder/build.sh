#!/usr/bin/env bash
set -euo pipefail

CONFIG_FILE="${1:-config.yml}"
BUILD_TAG="${2:-vault-gen:latest}"

echo "🔧 Reading config: $CONFIG_FILE"

# Parsuj dane z config.yml
BASE_IMAGE=$(yq e '.base_image' "$CONFIG_FILE")
PACKAGES=$(yq e '.packages // [] | join(" ")' "$CONFIG_FILE")
VAULT_VERSION=$(yq e '.vault_version // ""' "$CONFIG_FILE")
CMD=$(yq e -o=json '.cmd // []' "$CONFIG_FILE")
ENTRYPOINT=$(yq e -o=json '.entrypoint // []' "$CONFIG_FILE")

echo "📦 Base image: $BASE_IMAGE"
ctr=$(buildah from "$BASE_IMAGE")

mnt=$(buildah mount "$ctr")

# Instaluj pakiety
if [[ -n "$PACKAGES" ]]; then
  echo "📦 Installing packages: $PACKAGES"
  buildah run "$ctr" -- apt-get update
  buildah run "$ctr" -- apt-get install -y $PACKAGES
fi

# Pobierz Vault (jeśli podano)
if [[ -n "$VAULT_VERSION" ]]; then
  echo "⬇️ Downloading Vault $VAULT_VERSION"
  buildah run "$ctr" -- curl -sSLo /tmp/vault.zip "https://releases.hashicorp.com/vault/${VAULT_VERSION}/vault_${VAULT_VERSION}_linux_amd64.zip"
  buildah run "$ctr" -- unzip /tmp/vault.zip -d /usr/local/bin
  buildah run "$ctr" -- chmod +x /usr/local/bin/vault
fi

# Zmienne środowiskowe
echo "🌍 Setting env vars..."
yq e '.env // {} | to_entries[] | .key + "=" + .value' "$CONFIG_FILE" | while read -r env; do
  buildah config --env "$env" "$ctr"
done

# CMD & ENTRYPOINT
if [[ "$CMD" != "[]" ]]; then
  buildah config --cmd "$CMD" "$ctr"
fi
if [[ "$ENTRYPOINT" != "[]" ]]; then
  buildah config --entrypoint "$ENTRYPOINT" "$ctr"
fi

# Finalny obraz
echo "📦 Committing image as: $BUILD_TAG"
buildah commit "$ctr" "$BUILD_TAG"
