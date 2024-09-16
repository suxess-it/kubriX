# Backup

Overview how identity and access management works in our platform, at first, how initial setup will work:

## High-Level Overview

Keycloak is beeing installed via Helm Charts.
User and Credentials Configuration are currently served via Helm values file (ESO is on the roadmap) [see default values files](https://github.com/suxess-it/sx-cnp-oss/tree/main/platform-apps/charts/keycloak):

User are configured via groups:
admins: adminusers with admin entitlement
users: "normal" user entitlement
group1: "team" group entitlement

2FA with mobile Authenticator is added for users and group1

Extend Groups/Users to your needs

Github or other Identity Providers can be added to Keycloak, if neccessary

## Customizing Metrics
tbd
