# create metalstack cluster via terraform

# prereq

install terraform

```
curl -L -O https://releases.hashicorp.com/terraform/1.8.5/terraform_1.8.5_linux_amd64.zip
unzip terraform_1.8.5_linux_amd64.zip
mv terraform ~/bin
```

# create access token

create api token in console https://console.metalstack.cloud/

![screenshot_metalstack](https://github.com/suxess-it/kubriX/assets/11465610/a1ef3f11-6b03-4faf-90ab-6c16bb6b6fdd)

```
export METAL_STACK_CLOUD_API_TOKEN=<token-from-above>
```

execute terraform script

```
terraform plan
terraform apply
```
