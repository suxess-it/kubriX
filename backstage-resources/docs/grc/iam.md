# Backup

Overview how identity and access management works in our platform, at first, how initial setup will work:

## High-Level Overview

Keycloak is beeing installed via Helm Charts.
User and Credentials Configuration are currently served via Helm values file (ESO is on the roadmap) [see default values files](https://github.com/suxess-it/kubrix/tree/main/platform-apps/charts/keycloak):

User are configured via __groups__:
- __admins__: adminusers with admin entitlement
- __users__: "normal" user entitlement
- __team1__: "team" group entitlement

2FA with mobile Authenticator is added for group users and team1

Extend Groups/Users to your needs

Github or other Identity Providers can be added to Keycloak, if neccessary
- only __1__ github provider possible

## Customizing Metrics
tbd

## known behaviour

> Login failed; caused by Error: Failed to sign-in, unable to resolve user identity. Please verify that your catalog contains the expected User entities that would match your configured sign-in resolver.

Keycloak import must be finished after backstage startup - one of the last entries
```
2024-10-16T12:53:25.796Z catalog info Reading Keycloak users and groups class=KeycloakOrgEntityProvider taskId=KeycloakOrgEntityProvider:default:refresh taskInstanceId=03f28d78-f36d-44e6-9247-a497699b3baf
2024-10-16T12:53:25.887Z catalog info Read 7 Keycloak users and 5 Keycloak groups in 0.1 seconds. Committing... class=KeycloakOrgEntityProvider taskId=KeycloakOrgEntityProvider:default:refresh taskInstanceId=03f28d78-f36d-44e6-9247-a497699b3baf
2024-10-16T12:53:25.957Z catalog info Committed 7 Keycloak users and 5 Keycloak groups in 0.1 seconds. class=KeycloakOrgEntityProvider taskId=KeycloakOrgEntityProvider:default:refresh taskInstanceId=03f28d78-f36d-44e6-9247-a497699b3baf
```
