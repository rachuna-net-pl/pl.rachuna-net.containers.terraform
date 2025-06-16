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
OUTPUT_PATH="/usr/local/share/ca-certificates/bundle-ca.crt"

echo -e "\033[1;33m===>\033[0m Pobieranie CA certyfikatu dla rachuna-net.pl"

if [[ -z "$VAULT_ADDR" ]]; then
  echo "❌ Błąd: VAULT_ADDR nie jest ustawione"
  exit 1
fi

if [[ -z "$VAULT_TOKEN" ]]; then
  echo "❌ Błąd: VAULT_TOKEN nie jest ustawione"
  exit 1
fi

# Sprawdź, czy jq jest zainstalowane
if ! command -v jq &> /dev/null; then
  echo "❌ Błąd: jq nie jest zainstalowane. Zainstaluj jq, aby kontynuować."
  exit 1
fi

serials="79:82:d2:0e:c4:a2:64:eb:70:41:7e:e1:45:7a:d2:33:c7:1b:3a:78
7d:7a:0e:a4:25:15:ae:01:7a:75:b1:b3:a2:0c:8e:23:21:74:6c:ad
4f:01:92:ee:53:93:74:3b:77:02:64:10:9c:3b:78:a1:59:9c:08:63
43:7e:33:83:5b:61:17:73:ac:8b:f6:7f:42:10:a1:4a:0b:c4:e2:30
21:95:ff:fd:7b:65:ba:c5:3a:b9:52:57:36:2a:fc:74:e8:a8:10:58
15:1c:d3:83:38:2d:bb:de:22:28:3a:e0:5a:41:18:29:de:63:1b:02
"
> "$OUTPUT_PATH"

for serial in $serials; do
  echo "Pobieranie certyfikatu dla serialu: $serial"
  cert=$(curl -s -k -H "X-Vault-Token: $VAULT_TOKEN" "$VAULT_ADDR/v1/$PKI_PATH/cert/$serial" | jq -r '.data.certificate')
  echo "$cert" >> "$OUTPUT_PATH"
  echo "✅ Zapisano certyfikat: $OUTPUT_PATH"
done

update-ca-certificates
echo "✅ Zaktualizowano certyfikaty systemowe"