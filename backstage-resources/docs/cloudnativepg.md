# CloudNativePG

Overview how CloudNativePG works in our platform, at first, how initial setup will work:

## High-Level Overview

cnppg and pgadmin are beeing installed via Helm Charts.
User and Credentials Configuration are currently served via Helm values including ESO integration [see default values files](https://github.com/suxess-it/kubriX/tree/main/platform-apps/charts/cnpg):

Admin user is pgadmin4@kubrix.io, pwd see vault.
Predefined ServerDefinition is currently only valid for pgadmin4@kubrix.io user.

you can also login with predefined keycloak users.
- demoadmin
- demouser

## Customizing 
tbd