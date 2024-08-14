In this document are some runbooks for different problems listet.

## per-user series limit of 150000 exceeded (err-mimir-max-series-per-user)

When ingesting prometheus metrics to mimir you get the error `per-user series limit of 150000 exceeded (err-mimir-max-series-per-user)`.
Mimir has a configured limit of time series of 150k. This is on purpose because a higher number of time series could decrease performance and memory usage.
So before increasing the configured limit, you should take a look if your high series count is really needed.

Follow the steps in https://medium.com/@dotdc/how-to-find-unused-prometheus-metrics-using-mimirtool-a44560173543 to get all used and unused metrics in your environment.
Then follow https://medium.com/@dotdc/prometheus-performance-and-cardinality-in-practice-74d5d9cd6230 to drop unused metrics.


## err-mimir-tenant-max-ingestion-rate
???


## write to WAL - no space left on device

```
ts=2024-08-12T06:25:31.119841738Z caller=grpc_logging.go:76 level=warn method=/cortex.Ingester/Push duration=4.881001ms msg=gRPC err="user=gardener: write to WAL: log samples: write /data/tsdb/gardener/wal/00000727: no space left on device"
```

see https://community.grafana.com/t/mimir-ingesters-failing-on-no-space-left-on-device/66493/2

solution: increase ingester persistentVolume, like https://github.com/grafana/mimir/blob/fefa35e43bcc36c58f8baa3b1de0171b5f590b28/operations/helm/charts/mimir-distributed/capped-small.yaml#L62C3-L63

When increasing the PVC and syncing via ArgoCD the following sync error happens:

```
one or more objects failed to apply, reason: error when patching "/dev/shm/2228869740": StatefulSet.apps "sx-mimir-ingester-zone-a" is invalid: spec: Forbidden: updates to statefulset spec for fields other than 'replicas', 'ordinals', 'template', 'updateStrategy', 'persistentVolumeClaimRetentionPolicy' and 'minReadySeconds' are forbidden,error when patching "/dev/shm/2372432679": StatefulSet.apps "sx-mimir-ingester-zone-b" is invalid: spec: Forbidden: updates to statefulset spec for fields other than 'replicas', 'ordinals', 'template', 'updateStrategy', 'persistentVolumeClaimRetentionPolicy' and 'minReadySeconds' are forbidden,error when patching "/dev/shm/657813136": StatefulSet.apps "sx-mimir-ingester-zone-c" is invalid: spec: Forbidden: updates to statefulset spec for fields other than 'replicas', 'ordinals', 'template', 'updateStrategy', 'persistentVolumeClaimRetentionPolicy' and 'minReadySeconds' are forbidden. Retrying attempt #2 at 6:43AM.
```

How it worked in our environment with the example sts `sx-mimir-ingester-zone-c` (works the same for every other ingester of course).

1. disable auto-sync in bootstrap app and mimir app
2. resize pvc with `kubectl patch pvc -n mimir storage-sx-mimir-ingester-zone-c-0 -p '{"spec": {"resources": {"requests": {"storage": "'20Gi'"}}}}'`
3. after some time this pvc should have the new size. check with `kubectl get pvc -n mimir storage-sx-mimir-ingester-zone-c-0`
4. also the underlying pv should have the new size. check with: `kubectl get pv |grep storage-sx-mimir-ingester-zone-c-0`
5. orphan delete sts `sx-mimir-ingester-zone-c`
![image](https://github.com/user-attachments/assets/1fb576ca-3c1e-4a9f-a38a-b2c26baec9f2)

6. sync ingester sts `sx-mimir-ingester-zone-c`
![image](https://github.com/user-attachments/assets/1d0c39b1-b13a-4b9d-aabf-6636fd134105)

Matches with this (even though it is for Tempo) except that it doesn't explain the ArgoCD part: https://grafana.com/docs/tempo/latest/operations/ingester_pvcs/

TBD: we definitly need to monitor the ingester PVCs!


## Grafana - No data because scrapeInterval is 60 seconds

Set Min Step of 2 minutes if you use `$__rate_interval` and k8s-monitoring chart has default scrapeInterval of 60 seconds

see https://grafana.com/blog/2020/09/28/new-in-grafana-7.2-__rate_interval-for-prometheus-rate-queries-that-just-work/


### old documentation - DRAFT

1. Download mimirtool from [Grafana Website](https://grafana.com/docs/mimir/latest/manage/tools/mimirtool/#installation)
2. Create a Grafana API-Token (Roles 'Viewer') or get one from your Grafana system administrator
3. Get all used metrics in Grafana with this command:
```
$ mimirtool analyze grafana --address=<Grafana-URL> --key="<API-Key from step 2>"
```
A `metrics-in-grafana.json` file should get writte in your current directory.




references:

- https://github.com/suxess-it/sx-cnp-oss/issues/380
