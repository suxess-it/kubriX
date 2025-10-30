#!/usr/bin/env bash

# Safer prologue
set -Eeuo pipefail

shopt -s nullglob

# Simple error trap
fail() { printf '%s\n' "$1" >&2; exit "${2:-1}"; }
trap 'fail "Error on line $LINENO"' ERR

# basevariables
TMPDIR=".secrets/secrettemp"
SECRETFILE="secrets.yaml"
KUBE_CMD="kubectl"
VAULT_CMD="vault"
VAULT_ENABLED=false
SECRETKVNAME=kubrix-kv
CONFIGFILES=(.secrets/.env*.yaml)

if [ -f $TMPDIR/$SECRETFILE  ] ; then
  echo "secrets file $TMPDIR/$SECRETFILE already exists."
  echo "don't create new secrets."
  exit 0
fi

# check for yq
if ! command -v yq &> /dev/null; then
    echo "Error: missing yq binary!"
    exit 1
fi

if [ ${#CONFIGFILES[@]} -eq 0 ]; then
  echo "Error: missing config files"
  exit 1
fi

mkdir -p $TMPDIR
# reset file
> $TMPDIR/$SECRETFILE 
> $TMPDIR/push$SECRETFILE 
[ -f .secrets/secrettemp/secrets-applied ] && rm .secrets/secrettemp/secrets-applied #for local testing

for BASEFILE in "${CONFIGFILES[@]}"; do
  if [[ -f "$BASEFILE" ]]; then
    echo "🔍 Processing file: $BASEFILE"
  fi

# dynamic password generation
generate_secret() {
    local length=$1
    local charset=$2
    if [[ "$charset" == "alphanumeric" ]]; then
      echo $(openssl rand -base64 $((length * 2)) | tr -dc 'A-Za-z0-9' | head -c "$length")
    elif [[ "$charset" == "hex" ]]; then
      echo $(openssl rand -hex "$((length/2))")
    elif [[ "$charset" == "numeric" ]]; then
      echo $(openssl rand -base64 $((length * 2)) | tr -dc '0-9' | head -c "$length")
    else
      echo "Error: unknown charset $charset"
      exit 1
    fi
}

SECRET_COUNT=$(yq e '.secrets | length' "$BASEFILE")
# Process each secret individually
for ((i=0; i<SECRET_COUNT; i++)); do
    APP=$(yq e ".secrets[$i].application" "$BASEFILE")
    PAT=$(yq e ".secrets[$i].path" "$BASEFILE")
    NS=$(yq e ".secrets[$i].namespace" "$BASEFILE")
    SECRET_NAME=$(yq e ".secrets[$i].secretname" "$BASEFILE")
    SECRET_TYPE=$(yq e ".secrets[$i].secretType" "$BASEFILE")
    LABELS=$(yq e ".secrets[$i].labels" "$BASEFILE" | sed 's/^/    /')
    if [[ -z "$APP" || -z "$NS" || -z "$SECRET_NAME" || -z "$SECRET_TYPE" || -z "$PAT" ]]; then
        echo "Skipping invalid secret entry at index $i (missing required fields)."
        continue
    fi
    # create secret
    echo "generating secret: $SECRET_NAME for App: $APP, Namespace: $NS (type: $SECRET_TYPE)"
    echo "---" >> $TMPDIR/$SECRETFILE  # temp
    cat <<EOF >> "$TMPDIR/$SECRETFILE"
apiVersion: v1
kind: Namespace
metadata:
  name: $NS
---
apiVersion: v1
kind: Secret
metadata:
  name: $SECRET_NAME
  namespace: $NS
  annotations:
    kubrix.io/install: "true"
  labels:
$LABELS
type: Opaque
stringData:
EOF

    # create pushsecret
    echo "generating pushsecret: $SECRET_NAME-push for App: $APP, Namespace: $NS (type: $SECRET_TYPE)"
    echo "---" >> $TMPDIR/push$SECRETFILE  # temp
        cat <<EOF >> "$TMPDIR/push$SECRETFILE"
apiVersion: external-secrets.io/v1alpha1
kind: PushSecret
metadata:
  name: $SECRET_NAME-push
  namespace: $NS
  annotations:
    kubrix.io/install: "true"
spec:
  secretStoreRefs:
    - name: vault-backend
      kind: ClusterSecretStore
  refreshInterval: 15s
  selector:
    secret:
      name: $SECRET_NAME
  data:
EOF

    # Process stringData efficiently
    STRINGDATA_KEYS=$(yq e ".secrets[$i].stringData | keys | .[]" "$BASEFILE")
    for KEY in $STRINGDATA_KEYS; do
      HASHED="no"
      VALUE_TYPE=$(yq e ".secrets[$i].stringData[\"$KEY\"] | type" "$BASEFILE")
      if [[ "$VALUE_TYPE" != "!!str" ]]; then
          RAW_VALUE=$(yq e -r ".secrets[$i].stringData[\"$KEY\"] | tostring" "$BASEFILE")
          VALUE="\"$RAW_VALUE\""
      else
          VALUE=$(yq e -r ".secrets[$i].stringData[\"$KEY\"]" "$BASEFILE")
      fi
      # if VALUE is "-" it is just a placeholder
      #  so that the pushsecret references this variable, but it won't get created in the secret
      #  currently only for the 'hashed' use case, where we create a "${variable}Hash" variable,
      #  which gets created in the secret automatically, but also needs to get created in pushsecret
      if [[ "$VALUE" != "-" ]] ; then
        if [[ "$VALUE" =~ ^dynamic:([0-9]+):([a-zA-Z0-9_-]+)(:hashed)?$ ]]; then
            LENGTH=${BASH_REMATCH[1]}
            CHARSET=${BASH_REMATCH[2]}
            HASHED=${BASH_REMATCH[3]#:}
            VALUE=$(generate_secret "$LENGTH" "$CHARSET")
            echo "  -> generating dynamic secret for App: $APP, Value: $KEY (length: $LENGTH, $CHARSET, hashed: ${HASHED:-no})"
        fi
        # add stringData entry in Secret 
        if [[ "$VALUE" == *$'\n'* ]]; then
          printf "  %s: |-\n" "$KEY" >> "$TMPDIR/$SECRETFILE"
          printf "%s\n" "$VALUE" | sed 's/^/    /' >> "$TMPDIR/$SECRETFILE"
        # if string has no quotes then add some in the output
        elif [[ ! $VALUE =~ ^\".*\"$ ]]; then
          printf "  %s: \"%s\"\n" "$KEY" "$VALUE" >> "$TMPDIR/$SECRETFILE"
        # otherwise don't add them to prevent double quotes
        else
          printf "  %s: %s\n" "$KEY" "$VALUE" >> "$TMPDIR/$SECRETFILE"
        fi
        # if secret has the suffix 'hashed' create an additional secret hash with the key ${key}Hash
        if [[ "$HASHED" == "hashed" ]]; then
          printf "  %sHash: %s\n" "${KEY}" "$(htpasswd -bnBC 10 "" $VALUE | tr -d ':\n')" >> "$TMPDIR/$SECRETFILE"
        fi
      fi
    # Add data entry in PushSecret   
    cat <<EOF >> "$TMPDIR/push$SECRETFILE"
    - match:
        secretKey: $KEY
        remoteRef:
          remoteKey: $PAT
          property: $KEY
EOF
    done
done
done
echo "finished"
