#!/usr/bin/env bash
# Huellas del keystore que firma la app (ver signingConfigs en android/app/build.gradle).
# Copiar SHA-1 y SHA-256 en Firebase → App Android com.zonix.eats; luego descargar google-services.json.
set -euo pipefail
cd "$(dirname "$0")"
echo "=== :app signingReport (variante debug = flutter run) ==="
./gradlew :app:signingReport 2>/dev/null | grep -A 12 "^Variant: debug$" || true
