# Observability Dashboards

You can provide custom Grafana dashboards by adding **dashboard ConfigMaps** to your application configuration.

Each ConfigMap must include the following label so that Grafana automatically detects and imports it:

```
  labels:
    grafana_dashboard: "1"
```

Optionally, you can specify a **folder** in Grafana where the dashboard should appear by adding the following annotation:

```
  annotations:
    grafana_folder: "mySpecialFolder"
```

## Example
```
  labels:
    grafana_dashboard: "1"
  annotations:
    grafana_folder: "mySpecialFolder"
```

This setup allows your application to contribute individual dashboards that are automatically organized within Grafana.
