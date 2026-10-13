# Target applications

The target chart renders the platform's Argo CD Applications. Map mode lets
Helm merge individual application settings across values files.

## Map mode

New bootstrap Applications load these target-chart values files in order:

1. `values-kubrix-default.yaml`: enables map mode, defines the common stack,
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

The map key supplies the chart name, Application name (`sx-<key>`), and
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
The installer status table lists applications by numeric sync wave and then
alphabetically within the same wave. Missing sync-wave annotations mean wave `0`.

`KUBRIX_APP_EXCLUDE` sets map entries to `enabled: false` in the generated
target profile, including applications inherited from the common stack.

## Existing installations

`values.yaml` retains `applicationMap: false` and contains no map defaults.
Existing customer bootstrap Applications that load their own list-based target
profiles continue to work without modification:

```yaml
applications:
  - name: external-secrets
    syncOptions:
      - ServerSideApply=true
```

To migrate, convert the application's list into map entries, load
`values-kubrix-default.yaml` before the profile in the bootstrap Application, and
optionally load target-chart `values-customer.yaml` last. Profile files supplied
by kubriX now use map mode and require the shared defaults layer.
Do not mix a list-based profile with map defaults.

Map conversion preserves application settings. The shared sync waves
use the same three main phases in OSS and Prime. This change merges the former
waves -6 and 0; CI must validate stability and installation time before merge:

| Wave | Applications |
| --- | --- |
| -10 | prometheus-operator-crds, traefik, cert-manager, external-secrets, crossplane, external-dns |
| -8 | openbao, prometheus-blackbox-exporter |
| 0 | argocd, cnpg, loki, mimir, keycloak, k8s-monitoring and remaining applications, including backstage and team-onboarding |

MetalLB retains its earlier wave at -12. External DNS starts with the base
controllers at -10, using pre-provisioned provider credentials. Profiles inherit
shared waves instead of overriding them.
Peak's former duplicate `prometheus-operator-crds` entry is rendered once.

The installer creates Backstage tokens only when Backstage is selected, after
ArgoCD and any selected Grafana are Synced and Healthy. Set
`KUBRIX_SYNC_DEBUG=true` for state transitions, condition types, failed resource
identifiers and retry details without shell xtrace. Kind CI enables it explicitly.
Existing `KUBRIX_INSTALL_DEBUG=true` also enables these details.

Without debug, `[sync-recovery]` reports actual recovery actions, incomplete
termination and rejected sync requests. Normal completion/newer-operation
deferrals are debug-only. Each wait prints a compact `[sync-summary]` with total
accepted recovery syncs, observed failed operations and readiness regressions;
only apps with noteworthy counters or no observed readiness get individual rows.
Successful installation ends with `[install-summary]` and its elapsed seconds.

With debug enabled, each app also gets full statistics: latest/maximum observed
ArgoCD operation retry counts and seconds to first observed Synced/Healthy status.
A retry count belongs to one operation, so its maximum is not a total retry count.
Polling can miss short transitions; first readiness is not sustained readiness.
Failed operation counts include failed hooks even for Synced/Healthy apps.
Counters are collected in both modes; diagnostic observation never initiates syncs.

Debug-only `[sync-timing]` marks installation start/end separately from image
build, cluster creation and Playwright, plus the duration of each application wait.
Installation duration includes installer bootstrap/setup and final cleanup.
If installation aborts, the success end summary/marker is absent; use the failure
timestamp. Each wait has an ID: deduplicate replayed installer logs by wait ID
and app (or the exact event line) before comparing counters.
`KUBRIX_SYNC_DEBUG` defaults to false; kind CI explicitly enables it.

Before merging, compare each executed kind profile with 2–3 successful runs of
the same profile on main, including full `kind-hub-prime` in Prime.
Require successful installation and existing E2E tests. Investigate extra failed
operations, readiness regressions, repeated 300-second restarts and resource
pressure even if retries eventually recover. Compare medians/ranges of stack
installation time separately from the other CI stages; one green run does not
establish stability. Keep the current timeout/retry and Backstage-token guards.
If convergence or timing regresses, restore the six former -6 applications to
wave -6 rather than masking the regression with longer timeouts.

The 300-second recovery watchdog remains active even for Synced/Healthy resources
because sync hooks can still be stuck. Recovery re-reads the current operation,
does not terminate a newer operation, and waits up to 30 seconds (bounded by the
overall wait deadline) for Running/Terminating and pending operation state to
clear. Incomplete termination is deferred to the next installer loop. Natural
successful completion skips the restart. Monitoring's extra resync also waits
for an idle operation. Retry counters count accepted recovery sync requests;
deferred/rejected requests are logged separately. ArgoCD can still start an
operation between the final read and sync submission; rejected submissions are
deferred rather than assumed successful.

Debug-only `[sync-resource]` rows identify non-Synced or unhealthy resources
with group/kind/namespace/name, sync/health status and available health messages.
Resources that are Synced and have no health assessment (e.g. ConfigMaps) are
omitted. Application condition messages and failed operation/hook messages are
also included; operation reasons carry their operation start timestamp to
distinguish them from live resource health. A Succeeded operation does not
contribute old failure messages. Each app emits a snapshot only when the
reported resource status/reason changes, and an issues-cleared marker afterwards.
Messages are limited to 1000 characters, common credential patterns are
redacted and Secret resource messages are omitted. Manifests/Secret data are
never dumped. OutOfSync alone may have no explanatory message in Application
status; these rows do not include a manifest diff or container logs.

Normal ArgoCD refresh is requested for Degraded/Progressing/Unknown health or
Unknown/OutOfSync sync status, at most once every 30 seconds per app. The
returned Application JSON is evaluated in the same loop; if refresh fails,
cached status is retained. This applies independently of debug mode. There is
no hard refresh and no extra resource CLI call per app. This extends the
approaches proposed in OSS PRs #2229 (resource detail output) and #2797 (refresh
conditions).

## Validation

Run the compatibility, customer override, exclusion, and static profile checks
with Helm 3 and Mike Farah yq v4:

```bash
bash .github/tests/target-applications.sh
```
