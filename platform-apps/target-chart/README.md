# Target applications

The target chart renders the platform's Argo CD Applications. Dictionary mode lets
Helm merge individual application settings across values files.

## Dictionary mode

New bootstrap Applications load these target-chart values files in order:

1. `values-kubrix-default.yaml`: enables dictionary mode, defines the common stack,
   and configures optional applications without enabling them.
2. `values-<target>.yaml`: enables additional applications and overrides settings
   for the target.
3. `values-customer.yaml`: optional customer overrides at target-chart scope.

For example, a customer override can disable an inherited application and change
one annotation without replacing the other application settings:

```yaml
applications:
  keycloak:
    enabled: false
  external-secrets:
    annotations:
      argocd.argoproj.io/sync-wave: "-7"
  my-platform-app:
    enabled: true
    destinationNamespaceOverwrite: custom
```

The dictionary key supplies the chart name, Application name (`sx-<key>`), and
default destination namespace. A `name` field does not override the key. New
applications need `enabled: true`; existing applications inherit their enabled
setting. Setting `enabled: false` omits the Application. With automated pruning,
disabling an existing application removes it through the usual Argo CD lifecycle.

Application fields such as `annotations`, `syncOptions`, `helmOptions`,
`valueFiles`, `ignoreDifferences`, `destinationNamespaceOverwrite`,
`namespaceResourceTracking`, and `managedNamespaceMetadata` remain supported.
Maps merge recursively; lists such as `syncOptions` replace the inherited list.

Target-chart values files configure the Application resources themselves.
`default.valueFiles` and each application's `valueFiles` still configure the
values layers passed to the **child platform charts**. These are separate scopes.

Render a profile with its shared defaults:

```bash
helm template platform-apps/target-chart \
  -f platform-apps/target-chart/values-kubrix-default.yaml \
  -f platform-apps/target-chart/values-kind-security.yaml
```

The installer and CI use `.github/render-target-applications.sh <target>` to load
the target values files declared by the corresponding bootstrap Application.
`KUBRIX_APP_EXCLUDE` sets dictionary entries to `enabled: false` in the generated
target profile, including applications inherited from the common stack.

## Existing installations

`values.yaml` retains `applicationDict: false` and contains no dictionary defaults.
Existing customer bootstrap Applications that load their own list-based target
profiles continue to work without modification:

```yaml
applications:
  - name: external-secrets
    syncOptions:
      - ServerSideApply=true
```

To migrate, convert the application's list into dictionary entries, load
`values-kubrix-default.yaml` before the profile in the bootstrap Application, and
optionally load target-chart `values-customer.yaml` last. Profile files supplied
by kubriX now use dictionary mode and require the shared defaults layer.
Do not mix a list-based profile with dictionary defaults.

Migration preserves the rendered Applications and their settings. Peak formerly
contained two entries for `prometheus-operator-crds`; its dictionary retains the
last definition (sync wave `-8`) and renders it once.

## Validation

Run the compatibility, customer override, exclusion, and static profile checks
with Helm 3 and Mike Farah yq v4:

```bash
bash .github/tests/target-applications.sh
```
