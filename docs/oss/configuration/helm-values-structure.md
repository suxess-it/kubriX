# Configuration Structure of kubriX

## Challenges of a Modular, Preconfigured yet Flexible IDP Distribution

kubriX is intended to be more than just a collection of selected CNCF projects —
it aims to be a preconfigured Internal Developer Platform (IDP) that is both turnkey and modularly adaptable.

Our building blocks (“Bricks”) are delivered as Helm charts in the `platform-apps/charts` directory,
forming the foundation of the kubriX distribution.

To deliver what we believe to be the most stable, secure, and well-integrated configuration,
we need a concept that allows us to ship opinionated defaults while still enabling customers to adjust and extend the configuration as needed.

## Advantages of Our Configuration Structure

To achieve this, we follow an approach based on **modular Helm values files** that each handle specific configuration aspects.

This provides several advantages:

- kubriX can automatically deliver features that require specific Helm values — no need for customers to manually integrate settings based on documentation.
- Customers can extend or override kubriX defaults through their own values files. This makes it immediately clear what comes from the product and what is customer-specific.
  Customers can also override kubriX defaults if they don’t fit their environment.
- Modular, aspect-oriented values files make it possible to deliver configurations that only apply in certain environments (e.g. specific cluster types or cloud providers).
- Duplicate configurations are avoided, since values are not copied between files but inherited where relevant (following the **DRY principle**).
- Alternatively, a single template-based values file could be used, but such files tend to become overly complex, unmaintainable, and incompatible with static analysis tools like `helm lint` due to their dynamic elements.

## Challenges

Distributing Helm values across multiple files also brings certain challenges:

- Maintaining an overview of which values come from which files, and understanding the final rendered result
- Lists (arrays) cannot be partially overridden — they must be fully redefined even if only one element changes

To address these challenges, we employ:

- Tools that display the resulting computed values along with their configuration origins
- Rendered charts posted as PR comments in CI pipelines
- A design preference for **maps over lists** where possible, to avoid full-list overrides

## Types and Order of Values Files

The following table lists the values files in order of priority (later files override earlier ones).
All of these files are optional — in the simplest case, a Helm chart may consist only of an empty `values.yaml`,
thus relying entirely on the default values of its dependent sub-charts.

| Purpose | File Pattern | Example Filenames | Bootstrap-Installation Variable
|---|---|---|---|
| sane defaults | `values-kubrix-default.yaml` | - | - |
| Cluster type-specific values | `values-cluster-${clusterType}.yaml` | `values-cluster-kind.yaml`, `values-cluster-okd.yaml`, `values-cluster-gardener.yaml`  | KUBRIX_CLUSTER_TYPE |
| Cloud provider-specific values | `values-provider-${cloudProvider}.yaml` | `values-provider-metalstack.yaml`, `values-provider-aks.yaml`, `values-provider-eks.yaml` | KUBRIX_CLOUD_PROVIDER |
| High-availability (HA) configuration | `values-ha-enabled.yaml` | - | KUBRIX_HA_ENABLED |
| Sizing | `values-size-${tShirtSize}.yaml` | `values-size-small.yaml`, `values-size-small.yaml`, `values-size-small.yaml` | KUBRIX_TSHIRT_SIZE |
| Stricter security settings than default | `values-security-strict.yaml` | - |KUBRIX_SECURITY_STRICT |
| Customer-specific configuration generated during bootstrap (should not be manually modified) | `values-customer-generated.yaml` | - | KUBRIX_REPO, KUBRIX_DOMAIN, KUBRIX_DNS_PROVIDER, KUBRIX_GIT_USER_NAME, KUBRIX_CUSTOM_VALUES
| Customer-specific configuration maintained manually | `values-customer.yaml` | - | -

> 💡 **Info:** In some cases, certain aspects may be combined in one values file,
e.g. “XL sizing for a high-availability topology,” if the HA topology requires additional components and sizing adjustments.

# Defining the Overall Stack

To define which overall stack is installed with which values, a **“target type”** (equivalent to a kubriX stack) is defined.
This is specified in the `platform-apps/target-chart` directory in the file `values-${targetType}.yaml`.

A target type can be either generic and flexible (serving multiple use cases, but potentially more complex),
or very specific (tailored to one use case, but simpler to read).
The installation variable `KUBRIX_TARGET_TYPE` determines which stack will be installed.

Which of the above values files are included for each Helm chart in the stack is defined in `.default.valuesFiles`. 

To include all possible values files depending on installation variables, `.default.valuesFiles` should be defined as follows:

```
default:
  valueFiles:
  - values-kubrix-default.yaml
  - values-cluster-{{ .kubriX.clusterType }}.yaml
  - values-provider-{{ .kubriX.providerType }}.yaml
  {{ if .kubriX.highAvailability }}
  - values-ha-enabled.yaml
  {{ end -}}
  - values-size-{{ .kubriX.tShirtSize }}.yaml
  {{ if .kubriX.strictSecurity }}
  - values-security-strict.yaml
  {{ end -}}
  - values-customer-generated.yaml
  - values-customer.yaml
```

Additionally, the `.applications` attribute can be used to include or exclude charts depending on installation variables.


Example:
```
  # Do not install ingress-nginx if the cluster type is `kind`.
  {{ if ne .kubriX.clusterType "kind" -}}
  - name: ingress-nginx
    annotations:
      argocd.argoproj.io/sync-wave: "-11"
  {{ end -}}

  # Install aks-data-collector only if the cloud provider is `aks`.
  {{ if eq .kubriX.cloudProvider "aks" -}}
  - name: aks-data-collector
    annotations:
      argocd.argoproj.io/sync-wave: "-5"
  {{ end -}}
```

Furthermore, the installation variable `KUBRIX_APP_EXCLUDE` can be used to remove a specific application
from the `.applications` list, avoiding more complex `if`conditions.

> 💡 **Info:** Variables inside values files are rendered only during the bootstrap process —
that is, when the installation variable `KUBRIX_BOOTSTRAP` is set to `true`.








