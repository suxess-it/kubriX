# Observability

In this document we give an overview how observability in our platform works, its main components and how to configure the observability stack.

## High-Level Overview

![image](../img/kubrix-observe-topology.png)

Via [k8s-monitoring helm-chart](https://github.com/grafana/k8s-monitoring-helm) Grafana Alloy and some additional prometheus exporter (kube-state-metrics, node-exporter) are installed on the workload cluster to scrape important metrics, gather logs from pods and receive otel traces from applications.

A more detailed structure of this chart is available in https://github.com/grafana/k8s-monitoring-helm/blob/main/charts/k8s-monitoring/docs/Structure.md .

Alloy pushes the metrics to Mimir, logs to Loki and traces to Tempo. Grafana displays those informations in the corresponding dashboards.

## Customizing Metrics

k8s-monitoring helm charts get shipped with some [default metrics](https://github.com/grafana/k8s-monitoring-helm/blob/main/charts/k8s-monitoring/default_allow_lists/README.md)

You can customize them in the [metrics section](https://github.com/suxess-it/kubriX/blob/a610b6fafc1852326609fa9b5697b7163ab361f7/platform-apps/charts/k8s-monitoring/values-uibklab.yaml#L27-L99) of the values file and do also other [customizations](https://github.com/grafana/k8s-monitoring-helm/blob/main/charts/k8s-monitoring/docs/Customizations.md).

Application specific metrics can be scraped via Prometheus Operator CRDs or Annotations on your target pods, like described in [Scraping Additional Metrics](https://github.com/grafana/k8s-monitoring-helm/blob/main/charts/k8s-monitoring/docs/ScrapeApplicationMetrics.md).
