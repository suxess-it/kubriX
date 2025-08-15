
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

