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
Also, in combination with the [self-service app and app-namespace onboarding](https://github.com/suxess-it/kubriX/blob/main/backstage-resources/adr/0002-gitops-onboarding-apps.md#self-service-app-and-app-namespace-onboarding) it looks like an interesting approach we should get experiences with.
And this approach has flexibility for the dev-teams. They can use [very simple deployment-descriptors](https://github.com/suxess-it/kubriX/blob/main/team-apps/onboarding-apps-charts/multi-stage-app-with-kargo-pipeline/README.md#applicationset-with-scm-provider) or define their own applications by themselves. 

"Seperate namespace-scoped argocd instance for every team" is not a quick option in the kubriX stack and also has its downsides.
As long as we don't need seperate argocd instances from a scalability and better isolation perspective, I wouldn't go this way for now.

"Central gitops-Repo for app-projects, apps, namespaces and default configurations" can lead to a quite big central repo and needs lots of platform-team involvement.

### Consequences

- we need to find out if https://github.com/suxess-it/kubriX/issues/181 is a showstopper for applicationsets for "easy deployment-descriptors"
- since app-in-any-namespace has some special notes in the documentation that you should take care about misconfigurations, we should double-check if there is some misconfiguration which leads to a security issue.

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

Example implementation:

- https://developers.redhat.com/articles/2022/04/13/manage-namespaces-multitenant-clusters-argo-cd-kustomize-and-helm)

### Apps-in-any-Namespace and Multi-Tenant Kyverno-Policies

The platform-team onboards just the team by creating an argocd app-project for this team and a dedicated app-definition-namespace for this app-project. 
  The dev-team can then create new apps and app-namespace by themselves without interacting with the platform-team. This can be established with [apps-in-any-namespace](https://argo-cd.readthedocs.io/en/stable/operator-manual/app-any-namespace/). <br>
  To onboard a new dev-team, the platform-team
  - creates this "app-definition namespace" for this team (e.g. "adn-team1")
  - creates an argocd app-project for this team (e.g. team1-project), references the "app-definition namespace" in the projects sourceNamespaces attribute, sets the destinations in the project to valid "workload namespace pattern", like "team1-*" and sets clusterResourceWhitelist to "kind: Namespace".

The dev-team can 
create app-definitions in the "app-definition namespace" by themselves 
and set "CreateNamespace" sync option to automatically create the workload namespace for this application.
As long as the namespace name matches the valid destinations in the argo project (team1-*) the namespace gets created.

To create some default configurations automatically during namespace creation,
the platform team creates some kyverno [generate multi-tenancy policies](https://kyverno.io/policies/?policytypes=Multi-Tenancy).
Additionally [Namespace Metadata](https://argo-cd.readthedocs.io/en/stable/user-guide/sync-options/#namespace-metadata) can be used to apply different kyverno policies based on some labels or annotations.

In ArgoCD we need to set [application.namespaces](https://github.com/argoproj/argo-helm/blob/3174f52ffcfe3bb0d2ad6118411eacbaf20b0c7d/charts/argo-cd/values.yaml#L276) to allow some "app-definition namespace" (e.g. "adn-*" ).

Kargo Projects are also possible as a self-service - even though they are cluster-scoped ressources - with a special kyverno policy which checks the [kargo project name against the allowed argocd app-project destinations](https://github.com/suxess-it/kubriX/blob/main/platform-apps/charts/kyverno/templates/policy-kargo-project-name-validation-apps-in-any-ns.yaml).

pros:
- very high self-service for dev-teams
- no privilege escalation for dev-teams app-definitions possible, they need to stay in the teams app-project
- high standardization, security and soft-multi-tenancy standards for the namespaces because of kyverno generate policies for each namespace
- gitops-repo of the platform-team keeps quite manageable, because not every app-definition needs to be in this central gitops-repo

cons:
- applicationsets-in-any-namespace is still beta

consider:
- application names get longer (\<namespace\>/\<name\>). Be sure to have a good naming concept and consider https://argo-cd.readthedocs.io/en/latest/operator-manual/app-any-namespace/#switch-resource-tracking-method . 
- read through https://argo-cd.readthedocs.io/en/latest/operator-manual/app-any-namespace/ and understand what you do. misconfiguration could lead to potential security issues.

Example implementation: 

- [App-In-Any-Namespace-Config](https://github.com/suxess-it/kubriX/blob/ab3b44880a9936bddd781a2bf312e9f3e4d57a93/platform-apps/charts/argocd/values-k3d.yaml#L8-L9)
- [App-Definition-Namespace](https://github.com/suxess-it/kubriX/blob/main/platform-apps/charts/team-onboarding/templates/app-definition-ns.yaml)
- [team project](https://github.com/suxess-it/kubriX/blob/main/platform-apps/charts/team-onboarding/templates/app-project.yaml)
- [Generate Kyverno-Policies for new namespaces](https://github.com/suxess-it/kubriX/blob/main/platform-apps/charts/kyverno/templates/policy-add-ns-quota.yaml)


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

Example implementations: 

- [our own openshift implementation](https://github.com/suxess-it/ocp-infra)

  
# More information

## articles and resources

- https://github.com/cloudogu/gitops-patterns
- https://github.com/akuity/awesome-argo
- https://cloudogu.com/en/blog/gitops-repository-patterns-part-1-introduction


