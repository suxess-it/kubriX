# Bootstrap kubriX

## Fully automated bootstrapping

Steps:

1. create new empty customer repo on your Git-Server (GitLab, GitHub, Gitea, ...).

    IMPORTANT: the repo needs to be empty (also no initial README!!!)

2. create an access token for this new repo with write access
    
    Instead of a newly created access token you can also use your personal access tokens,
    but this is not recommended since your personal access token has probably more permissions than needed.

3. set the repo url and token in this variables like this:

    ```
    export KUBRIX_CUSTOMER_REPO="https://github.com/kubriX-demo/kubriX-demo-customerXY"
    export KUBRIX_CUSTOMER_REPO_TOKEN="blabla"
    ```

4. optional: set the domain, under which kubriX should be available.

    this domain will be used by external-dns.
    TODO: customizing external-dns is not explained here and not part of bootstrap yet. So it will only work with ionos and 'kubrix.cloud' domain.

    ```
    export KUBRIX_CUSTOMER_DOMAIN="demo-johnny.kubrix.cloud"
    ```

    if this variable is not set, a subdomain of "kubrix.cloud" is randomly created (for example "demo-2faf23d.kubrix.cloud")

5. optional: set the kubrix target type which should be used

    ```
    export KUBRIX_CUSTOMER_TARGET_TYPE="DEMO-STACK"
    ```

    if this variable is not set, "DEMO-STACK" is used.

6. create a new Kubernetes cluster and be sure that kubectl is connected to it. check with `kubectl cluster-info`

7. If you need to prepare something on your cluster do this now. We at kubriX for example need to create our ionos dns api key:

    ```
    kubectl create ns external-dns
    kubectl create secret generic ionos-credentials -n external-dns --from-literal=api-key='topsecret'
    ```

8. Then run this command in your home directory in your linux bash:

    ```
    curl -H 'Cache-Control: no-cache, no-store' https://raw.githubusercontent.com/suxess-it/kubriX/refs/heads/main/bootstrap/bootstrap.sh | bash -s
    ```

It will create a new kubriX repo based on your parameters and installs kubriX based on your created kubriX repo on your connected K8s cluster.


## background information

### customer specific parameters

In `bootstrap/customer-config.yaml` the customer specific parameters are set,
which are then used for rendering the chart values files.

### Rendering values templates

To create values files for specific instances in an automated 
way we render the values files with the template renderer `gomplate`

Source: https://github.com/hairyhenderson/gomplate
Docs: https://docs.gomplate.ca/

The command to render all values templates ending with '.yaml.tmpl' 
and write the result in the corresponding '.yaml' in the same directory:

```
bootstrap/bootstrap.sh
```

The used variables for the templates are defined in `bootstrap/customer-config.yaml` 
and are stored in the context `kubriX`.

### Example

Content of the `bootstrap/customer-config.yaml` is

```
domain: demo.kubrix.cloud
```

A `values-demo.yaml.tmpl` with the content
```
hostname: foo.{{ kubriX.domain }}
```

will then result in a `values-demo.yaml` with the content
```
hostname: foo.demo.kubrix.cloud
```

### Escaping helm brackets

When you want to use brackets `{{ }}` also in your values files 
(when using [variables in values files](https://helm.sh/docs/howto/charts_tips_and_tricks/#using-the-tpl-function) 
which should not get rendered by gomplate, then you need to escape them like this:

```
hostname: foo.{{`{{ .Values.global.bla }}`}}
```

then the output will be

```
hostname: foo.{{ .Values.global.bla }}
```

This is the same syntax as in argocd applicationsets in helm templates.

