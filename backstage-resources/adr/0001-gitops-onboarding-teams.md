# Onboarding teams in a gitops way

* Status: DRAFT
* Deciders: sX CNP oss Team
* Date: 2023-05-29

## Introduction

this document is a starting point
describing different approaches for gitops structures,
repos and processes.
Goal is to find gitops solutions
and describe which one fits to which purpose with pros and cons.

Be aware that there are many different gitops solutions,
because your whole solution includes:

- [operator deployment pattern](https://cloudogu.com/en/blog/gitops-repository-patterns-part-2-operator-deployment-patterns)
- [repository pattern](https://cloudogu.com/en/blog/gitops-repository-patterns-part-3-repository-patterns)
- [promotion pattern](https://cloudogu.com/en/blog/gitops-repository-patterns-part-4-promotion-patterns)
- [wiring pattern](https://cloudogu.com/en/blog/gitops-repository-patterns-part-5-wiring-patterns)

This ADR focuses more on the [wiring](https://cloudogu.com/en/blog/gitops-repository-patterns-part-4-promotion-patterns) part, especially how new teams and apps can be onboarded.

Some of the options below effect the patterns above and some don't. Maybe we can explore that in a next step.

This ADR depends also on ADR "002-gitops-onboarding-apps".


## Context and Problem Statement

As a
***platform-team***
I want a mechanism where I can onboard new teams and applications to a cluster with all required policies and standards
so that stability/security of the platform is still guaranteed and no negative effects to other teams and applications arise.


Normally onboarding teams and apps includes creating:
  - argocd app-project with restrictions (source-Repos, destinations, clusterResourceWhitelist, namespaceResourceBlacklist, ...) and roles if needed
  - argocd app
  - app namespaces
  - default configuration inside namespaces (limit-ranges, quotas, deny-all network-policies)
  - maybe some additonal platform-services (e.g. observability-tool ) also need to be configured for the new team/application/namespace (this isn't addressed in this ADR for now)

Depending on the solution some of this parts are done by the platform-team, by the dev-team, or automatically.

## Decision Drivers

- high self-service and low friction for dev-teams
- security-standards / multi-tenant configurations in place
- since not all teams have the same knowledge, some low-knowledge teams and also high-knowledge teams should get their best solution
- the solution should fit also to different "operator deployment patterns" and "promotion patterns"

## Considered Options

* Dev-Teams create tickets for platform-team
* Central gitops-Repo for app-projects, apps, namespaces and default configurations
* Apps-in-any-Namespace and Multi-Tenant Kyverno-Policies
* Seperate namespace-scoped argocd instance for every team

## Decision Outcome

I would like to propose the option "Apps-in-any-Namespace and Multi-Tenant Kyverno-Policies"
since it seems to be an interesting new solution which brings high self-service and good governance.
Also the namespace-as-a-service approach with kyverno generate-policies looks like an interesting approach we should get experiences with.
And this approach has flexibility for the dev-teams. They can use very simple deployment-descriptors or define their own applications by themselves. 

"Seperate namespace-scoped argocd instance for every team" is not a quick option in the sx-cnp-oss stack and also has its downsides.
As long as we don't need seperate argocd instances from a scalability and better isolation perspective, I wouldn't go this way for now.

"Central gitops-Repo for app-projects, apps, namespaces and default configurations" can lead to a quite big central repo and needs lots of platform-team involvement.

### Consequences

- we need to find out if https://github.com/suxess-it/sx-cnp-oss/issues/181 is a showstopper for applicationsets for "easy deployment-descriptors"

## Validation

tbd

## Pros and Cons of the Options

### Dev-Teams create tickets for platform-team

The dev-team creates a ticket for onboarding to the platform-team. platform-team creates the configurations by themselves without a possibility for devs to create PRs.

pros:
- platform-team can control app-definitions

cons:
- no self-service at all --> wait time for the dev-teams, high ticket load for the platform-team
- manual steps
- controlling app-definitions is not everything, the dev-teams still manage the app specific gitops-repo by themselves


### Central gitops-Repo for app-projects, apps, namespaces and default configurations

The platform-team has a gitops-repo with helm or kustomize. dev-teams create PRs to this gitops-repo and the platform-team reviews this PRs and merges them (maybe some additional automatic checks/pipelines help with reviewing the PR).

pros:
- high control for the platform-team
- every new application can be reviewed by the platform-team
- manifest creation can be tested in the gitops-repo and Pull-Request branches upfront
- since this is all in one repo, changes also get promoted and released together

cons:
- every new application needs to be reviewed by the platform-team (wait times, high load on the platform team)


### Apps-in-any-Namespace and Multi-Tenant Kyverno-Policies

The platform-team onboards just the team by creating an argocd app-project for this team and a dedicated app-definition-namespace for this app-project. 
  The dev-team can then create new apps and app-namespace by themselves without interacting with the platform-team. This can be established with [apps-in-any-namespace](https://argo-cd.readthedocs.io/en/stable/operator-manual/app-any-namespace/). <br>
  To onboard a new dev-team, the platform-team
  - extends the [value application.namespaces](https://github.com/argoproj/argo-helm/blob/3174f52ffcfe3bb0d2ad6118411eacbaf20b0c7d/charts/argo-cd/values.yaml#L276) with an "app-definition namespace" for this team (e.g. "team1-app-definitions" )
  - creates this "app-definition namespace" for this team (e.g. "team1-app-definitions")
  - creates an argocd app-project for this team (e.g. team1-project), references the "app-definition namespace" in the projects sourceNamespaces attribute, sets the destinations in the project to valid "workload namespace pattern", like "team1-*" and sets clusterResourceWhitelist to "kind: Namespace".

The dev-team can 
create app-definitions in the "app-definition namespace" by themselves 
and set "CreateNamespace" sync option to automatically create the workload namespace for this application.
As long as the namespace name matches the valid destinations in the argo project (team1-*) the namespace gets created.

To create some default configurations automatically during namespace creation,
the platform team creates some kyverno [generate multi-tenancy policies](https://kyverno.io/policies/?policytypes=Multi-Tenancy).
Additionally [Namespace Metadata](https://argo-cd.readthedocs.io/en/stable/user-guide/sync-options/#namespace-metadata) can be used to apply different kyverno policies based on some labels or annotations.

Kargo Projects are also possible as a self-service - even though they are cluster-scoped ressources - with a special kyverno policy which checks the [kargo project name against the allowed argocd app-project destinations](https://github.com/suxess-it/sx-cnp-oss/blob/main/platform-apps/charts/kyverno/templates/policy-kargo-project-name-validation-apps-in-any-ns.yaml).

pros:
- very high self-service for dev-teams
- no privilege escalation for dev-teams app-definitions possible, they need to stay in the teams app-project
- high standardization, security and soft-multi-tenancy standards for the namespaces because of kyverno generate policies for each namespace
- gitops-repo of the platform-team keeps quite manageable, because not every app-definition needs to be in this central gitops-repo

cons:
- apps-in-any-namespace is still beta, although it seems very stable
- applicationsets then have some restrictions (also when used by the platform team), see https://github.com/suxess-it/sx-cnp-oss/issues/181


### seperate namespace-scoped argocd instance for every team

The platform-team creates a seperate argocd instance (namespace-scoped) for this team.
Namespaced-scoped argocd instances can be managed by a central cluster-scoped argocd instance via gitops.
If this argocd instance should also manage some additional namespaces we need additional configs/roles/bindings
which is probably best managed with argocd operator (or openshift gitops operator on openshift).

The dev-team can create their argo projects by themselves or use the default project since it is limited by the scope of the namespace-scoped instance.

pros:
- higher isolation between teams concerning configurations, auth backend, permissions, resources and scalability

cons:
- higher resource consumption, higher management overhead, higher deployment complexity.

Example implementations: https://developers.redhat.com/articles/2022/04/13/manage-namespaces-multitenant-clusters-argo-cd-kustomize-and-helm


# Onboarding apps

For onboarding the applications there are again some different options.
Some are applicable to all team-onboarding-scenarios, some are just for specific team-onboarding scenarios.

We can probably draw this decision tree on a map in the future.

Therefore we discuss this app-onboarding options in the next section:

## Pros and Cons of the Options

### dev-team self-service app and app-namespace onboarding

Only applicable for team-onboarding option "Apps-in-any-Namespace and Multi-Tenant Kyverno-Policies"!
If you use this in a central argocd instance without "apps-in-any-namespace" there is a privilege-escalation-risk 
because the child-app in the app-of-apps repo can use any argocd app-project in this argocd instance and can deploy in any namespace (see https://github.com/argoproj/argo-cd/issues/2785)!

Dev-team creates a new argocd app-definition in their app-of-apps gitops-repo.
Therefore the platform-team needs to define a app-of-apps definition upfront which points to this gitops-repo.

ApplicationSets-in-any-namespace are also possible with some restrictions: https://github.com/suxess-it/sx-cnp-oss/issues/181
So Dev-Teams can create their own ApplicationSets without a platform-team. Without "Apps-in-any-Namespace" ApplicationSets were also only safe when platform-teams defined them, otherwise dev-teams could use any argocd app-project.

Example:
https://github.com/suxess-it/sx-cnp-oss/blob/12883d99657732d145d2992afa21b554403abd37/platform-apps/charts/argocd/values-k3d.yaml#L13-L16
and https://github.com/suxess-it/team1-apps/tree/main/k3d-apps 

pros:
- very high self-service for dev-teams without the need of a central managed applicationset
- no privilege escalation for dev-teams app-definitions possible, they need to stay in the teams app-project
- high standardization, security and soft-multi-tenancy standards for the namespaces because of kyverno generate policies for each namespace
- gitops-repo of the platform-team keeps quite manageable, because not every app-definition needs to be in this central gitops-repo

cons:
- apps-in-any-namespace is still beta, although it seems very stable
- applicationsets then have some restrictions (also when used by the platform team), see https://github.com/suxess-it/sx-cnp-oss/issues/181
- dev-team needs to have high knowledge of argocd app-definitions (could be enhanced with backstage scaffolder templates)

### ApplicationSet with simple "deployment descriptor"

Applicable for all team-onboarding options!

Platform-team creates an application-set per team during team-onboarding with static argo project reference.
Dev-Team creates their gitops-repos with highly simplified "deployment descriptor", which is in fact a helm values-file.
The Helm-Chart is stored in a different place (helm repo, git repo) managed by the platform team.
The Helm-Chart is very flexible configurable via the values file and has lots of sane defaults.
If you are fine with the sane defaults, you have a small values file, if you need special things, you have a bigger values file.

Example: tbd

pros:
- Dev-team only need a very simple value file. With sane defaults the value files content can be pretty small
- Dev-teams don't need helm or kubernetes resource manifests knowledge
- very slim and easy (but not so flexible) API
- new Parent-Chart versions rollout very fast (but you need to take care about staging and backward-compatibility)

cons:
- Dev-team has no option to define which K8s manifests and cannot add some additional resources.
- This option is always inflexible for bigger requirements, no matter how flexible the base-chart is
- maybe too less insights what is really going on for dev-teams (probably a matter of documentation and links to the base-chart)
- live-cycle-mgmt for the base-chart is hard, because changes need to be backward-compatible, since no version specification of the base-chart possible
- there is no source-of-truth in the dev-team gitops-repo, so deploying new versions of the app in the dev-stage can end in different results than in prod because the parent-chart is different between dev and prod

### ApplicationSet with Parent-Helm-Chart

Applicable for all team-onboarding options!

Platform-team creates an application-set per team during team-onboarding with static argo project reference.
dev-team creates gitops-repos containing a parent-helm-chart just with a values-File and referenced Sub-Chart,
which is maintained by a platform-team or some other base-chart maintainers.

Example: tbd

pros:
- dev-team knows better which other manifests get created, as long it knows the sources of the sub-chart
- dev-team can specify the version of the chart (renovate helps with updates)
- dev-team can add additional resources in the parent-charts templates-Folder

cons:
- tbd

### ApplicationSet with config.json representing a Parent-Helm-Chart

Applicable for all team-onboarding options!

Platform-team creates an application-set per team during team-onboarding with static argo project reference.
Dev-team creates a gitops-repo containing a config.json with definitions for helm repo, chart and version can be placed (todo: can this be implemented as optional with the same appset of option 1 or is it then mandatory).<br>

Example: https://github.com/thschue/gitops-demo/tree/main/demo

pros:
- dev-team doesn't need to know the helm structure (but needs to know our own config.json format)
- kubernetes resource best practices can be implemented centrally in this parent-chart

cons:
- config.json is proprietary, no "helm template" works out-of-the box and no renovate update


### Central gitops-Repo for app and app-namespace onboarding

Applicable only for team-onboarding option "Central gitops-Repo for app-projects, apps, namespaces and default configurations"

dev-team creates app-definition in argocd namespace via PR in central gitops-repo which represents the argocd apps.
platform-team needs to review the PR for every app definition if the correct argo project is referenced.

Example: tbd

pros:
- tbd

cons:
- central gitops-repo can get quite large and with lots of applications a dev-team could lose overview


### App onboarding for namespace-scoped argocd instance

Applicable only for team-onboarding option "Seperate namespace-scoped argocd instance for every team"

Dev-team creates a new argocd app-definition in their app-of-apps gitops-repo.
Therefore the platform-team needs to define a app-of-apps definition upfront which points to this gitops-repo.

Dev-team can create their argo projects by themselves or use default project since it is limited by the scope of the namespace-scoped instance. 
Additional namespaces need to be requested from the platform-team, since the namespaced-scope argocd is pinned to specific namespaces.

Example: tbd

pros:
- new apps is a complete self-service
- dev-team can make use of any configuration mgmt tools and kubernetes manifests which are possible

cons:
- new namespaces is not a self-service (compared to app-in-any-namespace)

# More information

## articles and resources

https://github.com/cloudogu/gitops-patterns
https://github.com/akuity/awesome-argo
https://cloudogu.com/en/blog/gitops-repository-patterns-part-1-introduction


