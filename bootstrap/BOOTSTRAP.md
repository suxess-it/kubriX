# BOOTSTRAP kubriX

## Fully automated bootstrapping

Prerequisites

1. create new empty customer repo

2. create an access token for this repo with write access

3. save the repo url and token in this variables like this:

```
KUBRIX_CUSTOMER_REPO="github.com/kubriX-demo/kubriX-demo-customerXY"
KUBRIX_CUSTOMER_REPO_TOKEN="blabla"
```

define another variable with our Domain, under which kubriX should be available

```
KUBRIX_CUSTOMER_DOMAIN="demo-johnny.kubrix.cloud"
```

If you need to prepare something on your cluster do this now.
We at kubriX for example need to create our ionos dns api key:

```
kubectl create ns external-dns
kubectl create secret generic ionos-credentials -n external-dns --from-literal=api-key='topsecret'
```


Then run this command in your home directory in your linux bash:

```
curl -H 'Cache-Control: no-cache, no-store' https://raw.githubusercontent.com/suxess-it/kubriX/refs/main/template-values-files/bootstrap/bootstrap.sh | bash -s -- ${KUBRIX_CUSTOMER_REPO} ${KUBRIX_CUSTOMER_REPO_TOKEN} ${KUBRIX_CUSTOMER_DOMAIN}
```

It will create a new kubriX repo based on your parameters and installs kubriX based on your created kubriX repo.

## background information

### create customer specific parameters

In `bootstrap/customer-config.yaml` the customer specific parameters need to get set,
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

