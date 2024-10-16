# RBAC Portal

Overview how RBAC works in Backstage on our platform, at first, how initial setup will work.

## High-Level Overview
Permission and RBAC is deactivated by default

Permission and RBAC Plugin generally activated in Backstage Container.

Configuration an app-config.yaml, additionally RBAC Rules can by adapted by configmap via Backstage Helm Charts.

app-config.yaml:
```
      permission:
        enabled: true
        rbac:
          pluginsWithPermission:
            - kubernetes
            - catalog
            - policy
            - scaffolder
            - rbac
          maxDepth: 1
          admin:
            users:
              - name: group:default/users
            superUsers:
              - name: user:default/demoadmin
          policies-csv-file: /opt/app-root/src/rbac/rbac-policy.csv
          policyFileReload: true
          database:
            enabled: true
```

rbac-policy.csv:
```
...
    p, role:default/kubrixdev, argocd.view.read, read, allow
    g, group:default/team1, role:default/kubrixdev
...
```

user and superUser can see RBAC ADministration Sidebar in Backstage Portal

## Customizing Metrics
tbd

## known behaviour

functionality is not widely adopted, tbd