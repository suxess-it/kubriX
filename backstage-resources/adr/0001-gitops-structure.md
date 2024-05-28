# gitops onboarding-process and repos

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

# Onboarding teams

## Context and Problem Statement

As a
***platform-team***
I want a mechanism where I can onboard new teams and applications to a cluster with all required policies and standards
so that stability/security of the platform is still guaranteed and no negative effects to other teams and applications arise.

As a
***dev-team***
I want to onboard and maintain my app as a self-service without high friction and wait times.
Still, I want to apply all platform-requirements and restriction with as much automation as possible.

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

# articles and resources

https://github.com/cloudogu/gitops-patterns
https://github.com/akuity/awesome-argo
https://cloudogu.com/en/blog/gitops-repository-patterns-part-1-introduction








# TODO: Old Content, maybe we integrate that later or delete it


# Considered options for different use-cases

Which options are for these user-stories?

As a
**dev-team with lots of knowledge in kubernetes, argocd, kustome and helm**
I want to onboard my app with high flexibility and with less governance as possible
to make use of any configuration mgmt tools and kubernetes manifests which are possible.
Still, I want a platform-team responsible for the cluster and the cluster is used by multiple dev-teams,
not just dedicated for one dev-team.


***option 7***

As a
**dev-team with lots of knowledge in kubernetes, argocd, kustome and helm**
I want to onboard my app with high flexibility and with less governance as possible
to make use of any configuration mgmt tools and kubernetes manifests which are possible.
The cluster is dedicated for my team, but I still want a platform-team which is responsible for the cluster-mgmt.

***option 8***

As a
**dev-team with lots of knowledge in kubernetes, argocd, kustome and helm**
I want to onboard my app with high flexibility and with less governance as possible
to make use of any configuration mgmt tools and kubernetes manifests which are possible.
The cluster is dedicated for my team and I take full responsibility for this cluster.
I use or copy some basic configurations from a platform-team but treat them more as a good practice which I can use or not.



## User Stories

TODO: maybe those are some pros/cons for the different approaches

These user stories a ordered by expertise of the platform consumers:

- little skills and knowledge - high standardization and governance
- medium skills and knowledge - high standardization, governance, but more flexibility and insights
- high skills and knowledge - very flexible, still some governance where needed and lots of insights

and the self-service capability of the platform

- namespace / project / tenant as a service
- ticket / PRs to platform-team and reviews required per app

Disclaimer: as always, enabling and "skill-up" dev-teams is always an advantages.
Still, some dev-teams are not able to skill them up or don't have enough resources.
Maybe, when this dev-teams get more experience their requirements towards more insights and flexibility
and less governance changes.
Also, maybe insights (which kubernetes-manifests are created, where do we have problems) are always helpful.
Then not so experienced teams can learn from the insights they get.
On the other way, also for experienced teams the platform should be easy to use, but not limiting in solutions.
That is all about golden paths instead of golden cages.



# TODO: maintaining / changing apps is different in each options above, we should highlight how this works then

# centrally controlled team-onboarding, self-service app onboarding 

team-onboarding via platform-repo, application onboarding self-service/automatically

Seems to be like
- User Story 1, option 4
- User Story 2, option 2 

## environemnt

Can be applied on the operator deployment pattern "Instance per Cluster" or "Hub and Spoke"

With the "instance per namespace" pattern this solution is probably not so useful,
because there the team-isolation is more on per-argocd-instance then on per-argo-project.
However, the app onboarding via applicationsets can be applied also on this pattern. 

## process

1. when onboarding the new team, the platform-team creates
    1. an argo project, so resource whitelists / blacklists / rbac can be defined by platform team
    2. applicationset with 
[SCM Provider generator](https://argo-cd.readthedocs.io/en/stable/operator-manual/applicationset/Generators-SCM-Provider/) or [Git generator](https://argo-cd.readthedocs.io/en/stable/operator-manual/applicationset/Generators-Git/) (depending of your repository pattern)
and using the defined argo project in step 1

    since this is also done via gitops, the dev-team could also create a PR in a central platform-repo for this

2. dev-teams create their gitops-repo based on the pattern defined in the applicationset in step 1.2 and the new application is automatically created

## pros

- new applications which match the applicationset pattern are automatically created without any review of a central platform team
- dev-team doesn't need to know the application definition

## cons

- platform-team needs to be fine with onboarding new applications without review. so some governance need to be in place (default policies in namespace, kyverno, netpol, resource-quotas, limit-ranges)
- since applicationsets are templates every application in this applicationset has very similar attributes or attributes need to be imported by config files per gitops-repo

## examples


## further implementation variations

- multiple sources so dev-teams only need to have some values in their repo and the chart is placed at some other place - see 'multiple sources' solution

- not only automatically app creation, but also kargo resources, namespace with some default resources, ... 


# team and application onboarding in central platform-repo, simple values, renders additional resources

like ARZ solution: 

simple values in central repo
not only automatically app creation, but also kargo resources, namespace with some default resources, ... 

be aware that those value files can be really big and onboarding new value files (corresponds to onbarding new teams) also needs a good implementation.(or values-patterns if that is possible now, e.g. values-team-*)


# application in different namespaces

# multiple sources

## examples

https://github.com/jkleinlercher/just-one-yaml-deployment/blob/main/argocd-config/just-one-yaml-applicationset.yaml

# helmfiles

# self-service and governance