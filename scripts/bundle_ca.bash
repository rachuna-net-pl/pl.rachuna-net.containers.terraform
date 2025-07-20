#!/bin/bash

# -----------------------------------------------------------------------------
# Skrypt: bundle_ca.bash
#
# Opis:
#   Skrypt pobiera wszystkie certyfikaty CA z backendu Vault PKI (domyślnie pki-root-ca)
#   Umożliwia to wygodne zebranie całego łańcucha certyfikatów CA dla domeny rachuna-net.pl.
#
# Wymagania:
#   - Zmienna środowiskowa VAULT_ADDR musi być ustawiona na adres serwera Vault.
#   - Zmienna środowiskowa VAULT_TOKEN musi być ustawiona na ważny token Vault.
#   - Narzędzie jq musi być zainstalowane w systemie.
#
# Działanie:
#   1. Pobiera listę seriali certyfikatów z Vault.
#   2. Dla każdego serialu pobiera certyfikat i zapisuje go do katalogu
#      /usr/local/share/ca-certificates.
# -

PKI_PATH="pki-root-ca"
NON_ROOT="true"
OUTPUT_PATH="$HOME/.local/share/ca-certificates/bundle-ca.crt"

echo -e ""

echo -e "\033[1;33m===>\033[0m 🔑  Pobieranie CA certyfikatu dla rachuna-net.pl"

if [[ -z "$VAULT_ADDR" ]]; then
  echo "  ❌  Błąd: VAULT_ADDR nie jest ustawione"
  exit 1
fi

if [[ -z "$VAULT_TOKEN" ]]; then
  echo "  ❌  Błąd: VAULT_TOKEN nie jest ustawione"
  exit 1
fi

# Sprawdź, czy jq jest zainstalowane
if ! command -v jq &> /dev/null; then
  echo "  ❌  Błąd: jq nie jest zainstalowane. Zainstaluj jq, aby kontynuować."
  exit 1
fi

[[ "$NON_ROOT"=="true" ]] && mkdir -p $HOME/.local/share/ca-certificates

serials="4a:ee:dc:18:d8:a3:03:f5:13:7e:c3:87:b3:84:c2:93:35:60:a2:ad
4c:3c:f6:dc:9d:08:bc:e6:67:44:f8:36:8e:ef:e8:40:92:4b:f5:88
5f:c7:87:61:c2:5c:48:42:6c:aa:e0:2c:aa:11:11:43:37:81:c6:db
3e:af:c6:0b:df:31:ee:80:83:ab:17:48:05:2d:22:07:d0:b0:04:b9
19:87:e6:84:62:a1:f3:5d:17:bf:0d:7d:7d:75:52:f3:7d:22:e0:42
0d:89:a0:cb:5d:df:01:d5:69:77:9a:49:44:dc:8c:ee:fe:77:52:91
"
> "$OUTPUT_PATH"

for serial in $serials; do
  echo -e ""
  echo "Pobieranie certyfikatu dla serialu: $serial"
  cert=$(curl -s -k -H "X-Vault-Token: $VAULT_TOKEN" "$VAULT_ADDR/v1/$PKI_PATH/cert/$serial" | jq -r '.data.certificate')
  echo "$cert" >> "$OUTPUT_PATH"
  echo "  ✅  Zapisano certyfikat: $OUTPUT_PATH"
done

if [[ "$NON_ROOT"=="true" ]]; then
  export CURL_CA_BUNDLE="$OUTPUT_PATH"
  export GIT_SSL_CAINFO="$OUTPUT_PATH"
  export PIP_CERT="$OUTPUT_PATH"
else 
  echo -e ""
  update-ca-certificates
fi

echo -e "  ✅  Zaktualizowano certyfikaty systemowe"