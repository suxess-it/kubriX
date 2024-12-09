# Onboarding applications

# New Apps via Scaffolder Templates and ArgoCD AppSets

When your team creates applications with some specific conventions which applies to the platform ApplicationSets, then your app is automatically deployed via a platform ApplicationSet and you don't need to deal with any ArgoCD application definitions.

For Showcase-Purposes there is an AppSet for "Multi-Stage Apps with Kargo-Pipeline" available which searches for repos in your organization which

* start with your teams name, e.g. `team-1-my-app`
* have a `app-stages.yaml` in the root folder of your repo

With the scaffolder [template for multi-stage app with kargo pipeline](https://backstage.demo.kubrix.cloud/create/templates/default/multi-stage-app-with-kargo-pipeline) you can automatically create such a repo with the predefined example application 'podtato-head'.

![image](../img/app-onboarding-1.png)

Just specifiy your application name and a description and be sure that the "FQDN" points to `demo.kubrix.cloud`. Then click 'Next'.

![image](../img/app-onboarding-2.png)

The Git-Repo for your applications Kubernetes resources is automatically set, just click 'Next'.

![image](../img/app-onboarding-3.png)

On the summary page review your data and click on 'Create'

![image](../img/app-onboarding-4.png)

Backstage now creates a new Git-Repo with the needed Helm-Chart in it and registers this new app in backstage. With 'Repository' you can open the Git-Repository and with 'Open in catalog' you will open the corresponding application component in backstage.

![image](../img/app-onboarding-5.png)

In the backstage component overview of your application you can see the ArgoCD sync and health status. It may take a few seconds until your app is recognized bei the ArgoCD ApplicationSet and synced in ArgoCD. You can click on the application name to open the corresponding argocd dashboard.

![image](../img/app-onboarding-6.png)

On the bottom of the component overview page you can see that this application has three subcomponents, one per stage.
You can click on each subcomponent and get to the overview page of each subcomponent.

![image](../img/app-onboarding-7.png)

Each component page has different tabs for different informations.

![image](../img/app-onboarding-8.png)

* Overview: some key informations for your app from different tools and links to e.g. interesting Grafana Dashboards
* Kargo: GitOps-Promotion tool to bring your changes from dev to prod (Password in demo env: 'admin')

![image](../img/app-onboarding-10.png)

* Kubernetes: shows your app specific resources and state in your Kubernetes cluster
* Docs: shows your application documentation
* Pull Requests: Pull Requests of your application gitops-Repo
* Github issues: Issues of your application gitops-Repo
* Github Insights: overview of your application gitops-Repo
* Grafana Dashboard: overview of your application resource consumption and health state (User: admin, Password: prom-operator)

![image](../img/app-onboarding-12.png)

And at the bottom of your components overview page, you see the ArgoCD status and a link to open your application.

![image](../img/app-onboarding-9.png)

![image](../img/app-onboarding-11.png)


# New apps via Team-App-Of-Apps Repo

Experienced teams can create their own ArgoCD application definition or AppSets in their Team-App-Of-Apps repo created in the "Onboarding Team" step.
This application definition can point to any GitOps-Repo as long as

* ArgoCD is able to read this repo
* it meets the 'sourceRepos' rules in the [team-onboarding values](https://github.com/kubriX-demo/kubriX-demo/blob/main/platform-apps/charts/team-onboarding/values-demo-metalstack.yaml)

Please be aware that depending on the ArgoCD project definition it is very likely that your team can only deploy namespace-scoped resources in namespaces beginning with your team name (e.g. 'team-1-app-1').


# Additional infos

Some background information can also be found in the [Additional infos](additional-infos.md) chapter.
