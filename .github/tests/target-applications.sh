#!/usr/bin/env bash
# Requires Helm 3 and Mike Farah yq v4; no cluster or chart dependencies needed.
set -euo pipefail
chart=platform-apps/target-chart
test_dir=$(mktemp -d)
trap 'rm -rf "$test_dir"' EXIT

cat > "$test_dir/legacy.yaml" <<'YAML'
default:
  valueFiles: [values-kubrix-default.yaml, values-customer.yaml]
applications:
  - name: example
    annotations:
      argocd.argoproj.io/sync-wave: "-5"
    destinationNamespaceOverwrite: shared
    namespaceResourceTracking: false
    helmOptions:
      skipCrds: true
    valueFiles: [values-example.yaml]
    syncOptions: [ServerSideApply=true]
    ignoreDifferences:
      - group: apps
        kind: Deployment
        jsonPointers: [/spec/replicas]
  - name: other
    managedNamespaceMetadata:
      labels:
        owner: platform
YAML
# Supply the same configuration through dictionary mode and compare all fields.
yq '.applications |= (map({"key": .name, "value": (. | del(.name) | .enabled = true)}) | from_entries) | .applicationDict = true' "$test_dir/legacy.yaml" > "$test_dir/dictionary.yaml"
helm template "$chart" -f "$test_dir/legacy.yaml" > "$test_dir/legacy-render.yaml"
helm template "$chart" -f "$test_dir/dictionary.yaml" > "$test_dir/dictionary-render.yaml"
for format in legacy dictionary; do
  yq ea -o=json -I=0 '[.] | sort_by(.metadata.name)' "$test_dir/$format-render.yaml" > "$test_dir/$format.json"
done
diff -u "$test_dir/legacy.json" "$test_dir/dictionary.json"
# A list loaded with dictionary mode should fail clearly rather than prune apps.
if helm template "$chart" -f "$test_dir/legacy.yaml" --set applicationDict=true > "$test_dir/invalid.yaml" 2> "$test_dir/invalid.log"; then
  echo "Expected list/dictionary mode mismatch to fail" >&2
  exit 1
fi
grep -q 'applicationDict=true requires applications to be a dictionary' "$test_dir/invalid.log"

# A partial customer override must retain shared settings and omit disabled apps.
cat > "$test_dir/customer.yaml" <<'YAML'
applications:
  keycloak:
    enabled: false
  external-secrets:
    annotations:
      argocd.argoproj.io/sync-wave: "-7"
  customer-app:
    enabled: true
    name: ignored-name
    destinationNamespaceOverwrite: custom
YAML
helm template "$chart" -f "$chart/values-kubrix-default.yaml" -f "$chart/values-kind-security.yaml" -f "$test_dir/customer.yaml" > "$test_dir/customer-render.yaml"
yq ea -e '[select(.metadata.name == "sx-keycloak")] | length == 0' "$test_dir/customer-render.yaml" > /dev/null
yq -e 'select(.metadata.name == "sx-external-secrets") | .metadata.annotations."argocd.argoproj.io/sync-wave" == "-7" and (.spec.syncPolicy.syncOptions | contains(["ServerSideApply=true"]))' "$test_dir/customer-render.yaml" > /dev/null
yq -e 'select(.metadata.name == "sx-customer-app") | .spec.source.path == "platform-apps/charts/customer-app" and .spec.destination.namespace == "custom"' "$test_dir/customer-render.yaml" > /dev/null

# Exclusion must override an inherited enabled app even absent from the profile.
cp "$chart/values-kind-security.yaml" "$test_dir/excluded.yaml"
EXCLUDED_APP=external-secrets yq '.applications[strenv(EXCLUDED_APP)].enabled = false' -i "$test_dir/excluded.yaml"
helm template "$chart" -f "$chart/values-kubrix-default.yaml" -f "$test_dir/excluded.yaml" > "$test_dir/excluded-render.yaml"
yq ea -e '[select(.metadata.name == "sx-external-secrets")] | length == 0' "$test_dir/excluded-render.yaml" > /dev/null

# Installer status order follows numeric sync waves, then application names.
cat > "$test_dir/waves.yaml" <<'YAML'
default:
  valueFiles: [values-kubrix-default.yaml]
applications:
  - name: aaa-ten
    annotations:
      argocd.argoproj.io/sync-wave: "10"
  - name: bbb-zero
    annotations:
      argocd.argoproj.io/sync-wave: "0"
  - name: ccc-default
  - name: ddd-two
    annotations:
      argocd.argoproj.io/sync-wave: "2"
  - name: mmm-minus-two
    annotations:
      argocd.argoproj.io/sync-wave: "-2"
  - name: zzz-minus-eleven
    annotations:
      argocd.argoproj.io/sync-wave: "-11"
YAML
yq '.applications |= (map({"key": .name, "value": (. | del(.name) | .enabled = true)}) | from_entries) | .applicationDict = true' "$test_dir/waves.yaml" > "$test_dir/waves-dictionary.yaml"
for format in waves waves-dictionary; do
  target_chart_value_args=( -f "$test_dir/$format.yaml" )
  eval "$(sed -n '/^base_apps=$(helm template /p' install-platform.sh)"
  [[ "$base_apps" == "sx-zzz-minus-eleven sx-mmm-minus-two sx-bbb-zero sx-ccc-default sx-ddd-two sx-aaa-ten " ]] || {
    echo "Incorrect installer sync-wave order ($format): $base_apps" >&2
    exit 1
  }
done

# Bootstrap discovery must match the layered chart render for every static profile.
for profile in "$chart"/values-*.yaml; do
  target=${profile##*/values-}
  target=${target%.yaml}
  [[ -f "bootstrap-app-$target.yaml" ]] || continue
  bash .github/render-target-applications.sh "$target" > "$test_dir/$target.yaml"
  helm lint "$chart" -f "$chart/values-kubrix-default.yaml" -f "$profile" > /dev/null
  helm template "$chart" -f "$chart/values-kubrix-default.yaml" -f "$profile" > "$test_dir/direct.yaml"
  diff -u "$test_dir/direct.yaml" "$test_dir/$target.yaml"
  # Exercise the actual installer/CI discovery expressions, not a copy of them.
  target_chart_value_args=( -f "$chart/values-kubrix-default.yaml" -f "$profile" )
  eval "$(sed -n '/^base_apps=$(helm template /p' install-platform.sh)"
  read -r -a discovered_apps <<< "$base_apps"
  expected_count=$(yq ea '[select(.kind == "Application")] | length' "$test_dir/$target.yaml")
  [[ ${#discovered_apps[@]} == "$expected_count" ]] || {
    echo "Installer discovery contains extra tokens for $target: $base_apps" >&2
    exit 1
  }
  for app in "${discovered_apps[@]}"; do
    [[ "$app" == sx-* ]] || { echo "Unexpected installer application: $app" >&2; exit 1; }
  done
  eval "$(sed -n '/enabled_apps=$(bash .github\/render-target-applications.sh /p' .github/workflows/cluster-test.yml)"
  mapfile -t ci_apps <<< "$enabled_apps"
  [[ ${#ci_apps[@]} == "$expected_count" ]] || {
    echo "CI discovery contains extra tokens for $target: $enabled_apps" >&2
    exit 1
  }
done
echo "Target application compatibility, layering, exclusion, and profile checks passed."
