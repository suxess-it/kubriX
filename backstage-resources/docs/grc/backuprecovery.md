# Backup

Overview how backup/recovery works in our platform, at first, how initial setup will work:

## High-Level Overview

Velero and Velero UI is beeing installed via Helm Charts.
User Credentials are served via Vault and exposed by External Secrets Operator, currently [default values](https://github.com/suxess-it/kubriX/blob/36a080dcc13c23d3d514fbba24e5dce79d29dcdb/platform-apps/charts/vault/templates/crossplane/cp-kv2-demosecretjson.yaml) are used:

## Customizing Metrics
In Local Demo Environment we use uploaderType restic and set defaultVolumeToFsBackup to true, in production environment we suggest you to use Kopia, CSI Snapshotting and DataMover for efficient Backup Strategy. This is also due to restic beeing deprecated in next Velero Releases.

Having Certificates for S3 Endpoints there are 2 ways implementing this:
- using caCert and adding base64 encoded string
- adding Certificate via Secret/Configmap to all involved Container, and adding AWS_CA_BUNDLE variable to velero deployment

cacert must be added to your local velero client configuration:
$ velero client config set cacert=<ca file> [see Velero Documentation](https://velero.io/docs/v1.14/self-signed-certificates/#trusting-a-self-signed-certificate-with-the-velero-client)

## Checking Endpoint:
Use aws s3api client for checking Content on S3 Endpoint
$ aws s3api --endpoint-url <Endpoint> list-objects --bucket <bucketname> --debug | jq -r '.Contents[].Key'

## Which Resources should get backuped for kubriX platform

### Kargo

Kargo creates `freights` and `promotions`. If they are lost you loose your freight line and your promotion state of the pipeline, see https://github.com/akuity/kargo/discussions/3126 .

- `Freight.kargo.akuity.io`
- `Promotion.kargo.akuity.io`

These types are defined automatically in a velero scheduler via [-include-resource flag](https://velero.io/docs/main/resource-filtering/#--include-resources)

## Opt-In other resources

Other resources (also applications) can opt-in by defining a label `backup.kubrix.io/tier` and a value from `critical`, `standard` or `archive`. 
Velero has a default scheduler which backups labeled resources by using a [-selector option](https://velero.io/docs/main/resource-filtering/#--selector).

- critical: hourly
- standard: daily
- archive: weekly

💡 Extra tip:
If you can’t label every resource directly, you could label the namespace with `backup.kubrix.io/tier=critical` → Velero selectors will match all objects in that namespace.


