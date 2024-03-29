see https://kubernetes-sigs.github.io/external-dns/v0.14.1/tutorials/aws/#iam-policy
and https://kubernetes-sigs.github.io/external-dns/v0.14.1/tutorials/aws/#static-credentials
what you need to do in AWS to get the required policy and user/passwort for static credentials.
That is only used when deploying the platform-stack outside of AWS.
Otherwise you can set IAM roles on serviceaccounts.

In https://kubernetes-sigs.github.io/external-dns/v0.14.1/tutorials/aws/#manifest-for-clusters-without-rbac-enabled
is documented how the deployment.yaml should get modified (hopefully via helm chart values)

