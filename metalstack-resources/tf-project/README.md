# create metalstack cluster via terraform

# prereq

install terraform

```
curl -L -O https://releases.hashicorp.com/terraform/1.8.5/terraform_1.8.5_linux_amd64.zip
unzip terraform_1.8.5_linux_amd64.zip
mv terraform ~/bin
```

# create access token

```
export METAL_STACK_CLOUD_API_TOKEN=<token-from-above>
```

execute terraform script

```
terraform plan
terraform apply
```
