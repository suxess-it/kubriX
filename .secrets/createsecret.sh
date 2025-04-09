#!/bin/bash

# basevariables
TMPDIR="secrettemp"
SECRETFILE="secrets.yaml"
KUBE_CMD="kubectl"
VAULT_CMD="vault"
VAULT_ENABLED=false
SECRETKVNAME=kubrix-kv
CONFIGFILES=(.env*.yaml)

# check for yq
if ! command -v yq &> /dev/null; then
    echo "Error: missing yq binary!"
    exit 1
fi

if [ ${#CONFIGFILES[@]} -eq 0 ]; then
  echo "Error: missing config files"
  exit 1
fi

# reset file
> $TMPDIR/$SECRETFILE 
> $TMPDIR/push$SECRETFILE 
> $TMPDIR/external$SECRETFILE 

for BASEFILE in "${CONFIGFILES[@]}"; do

# vault?
VAULT_ENABLED=$(yq eval '.vault.enabled' $BASEFILE)
VAULT_ADDR=$(yq eval '.vault.address' $BASEFILE)
VAULT_PATH=$(yq eval '.vault.path' $BASEFILE)
VAULT_TOKEN=$(yq eval '.vault.token' $BASEFILE)

if [[ "$VAULT_ENABLED" == "true" ]]; then
    export VAULT_ADDR
    export VAULT_TOKEN
    echo "vault activated: pushing secrets after vault available."
fi

# dynamic password generation
generate_secret() {
    local length=$1
    local charset=$2
    if [[ "$charset" == "alphanumeric" ]]; then
        tr -dc 'A-Za-z0-9' </dev/urandom | head -c "$length"
    elif [[ "$charset" == "hex" ]]; then
        openssl rand -hex "$((length/2))"
    elif [[ "$charset" == "numeric" ]]; then
        tr -dc '0-9' </dev/urandom | head -c "$length"
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

    # tmpdir for secret creation
    #mkdir -p $TMPDIR
    #SECRET_FILE="$TMPDIR/$SECRET_NAME.env"
    #> "$SECRET_FILE"

    # create secret
    echo "generating secret: $SECRET_NAME for $APP in namespace $NS (type: $SECRET_TYPE)"
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
    echo "generating pushsecret: $SECRET_NAME-push for $APP in namespace $NS (type: $SECRET_TYPE)"
    echo "---" >> $TMPDIR/push$SECRETFILE  # temp
        cat <<EOF >> "$TMPDIR/push$SECRETFILE"
apiVersion: external-secrets.io/v1beta1
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

    echo "generating externalsecret: $SECRET_NAME-external for $APP in namespace $NS (type: $SECRET_TYPE)"

    echo "---" >> $TMPDIR/external$SECRETFILE  # temp
    cat <<EOF >> "$TMPDIR/external$SECRETFILE"
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: $SECRET_NAME-external
  namespace: $NS
spec:
  refreshInterval: 1h
  secretStoreRef:
    name: external-secret-store
    kind: SecretStore
  target:
    deletionPolicy: Retain
    name: $SECRET_NAME
    creationPolicy: Owner
    template:
      type: $SECRET_TYPE
      metadata:
        annotations:
          kubrix.io/install: "false"
      data:
EOF

    # Process stringData efficiently
    STRINGDATA_KEYS=$(yq e ".secrets[$i].stringData | keys | .[]" "$BASEFILE")
    for KEY in $STRINGDATA_KEYS; do
        VALUE=$(yq e -r ".secrets[$i].stringData[\"$KEY\"]" "$BASEFILE")
      #  VALUE=$(yq e ".secrets[$i].stringData[\"$KEY\"]" "$BASEFILE" | tr -d '\n' | sed 's/^[ \t]*//;s/[ \t]*$//')

        if [[ "$VALUE" =~ ^dynamic:([0-9]+):([a-zA-Z0-9_-]+)$ ]]; then
            LENGTH=${BASH_REMATCH[1]}
            CHARSET=${BASH_REMATCH[2]}
            VALUE=$(generate_secret "$LENGTH" "$CHARSET")
            echo "  -> generating dynamic secret $KEY ($LENGTH length, $CHARSET)"
        fi
        #echo "$KEY=$VALUE" >> "$SECRET_FILE"
    # add stringData entry in Secret 
    if [[ "$VALUE" == *$'\n'* ]]; then
      # format json 
      VALUE="$(echo "$VALUE" | tr -d '\n' | sed 's/^[ \t]*//;s/[ \t]*$//')"
      printf "  %s: |\n    %s\n" "$KEY" "$VALUE" >> "$TMPDIR/$SECRETFILE"
    else
      printf "  %s: %s\n" "$KEY" "$VALUE" >> "$TMPDIR/$SECRETFILE"
    fi
#    cat <<EOF >> "$TMPDIR/$SECRETFILE"
#  $KEY: $VALUE
#EOF
    # Add data entry in ExternalSecret
    cat <<EOF >> "$TMPDIR/external$SECRETFILE"
        $KEY: "{{ \`{{ .${KEY} }}\` }}"
EOF
    # Add data entry in PushSecret   
    cat <<EOF >> "$TMPDIR/push$SECRETFILE"
    - match:
        secretKey: $KEY
        remoteRef:
          remoteKey: $PAT
          property: $KEY
EOF
    done
# add data entry in ExternalSecret
    cat <<EOF >> "$TMPDIR/external$SECRETFILE"
  data:
EOF

# add data entry in ExternalSecret
    for KEY in $STRINGDATA_KEYS; do
        cat <<EOF >> "$TMPDIR/external$SECRETFILE"
  - secretKey: $KEY
    remoteRef:
      key: $SECRETKVNAME/data/$APP
      property: $KEY
EOF
done
done
done
echo "finished"
