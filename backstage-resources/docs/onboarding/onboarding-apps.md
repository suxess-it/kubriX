# Onboarding applications

# New Apps via Scaffolder Templates and ArgoCD AppSets

When your team creates applications with some specific conventions which applies to the platform ApplicationSets, then your app is automatically deployed via a platform ApplicationSet and you don't need to deal with any ArgoCD application definitions.

For Showcase-Purposes there is an AppSet for "Multi-Stage Apps with Kargo-Pipeline" available which searches for repos in your organization which

* start with your teams name, e.g. `team-1-my-app`
* have a `app-stages.yaml` in the root folder of your repo

With the scaffolder [template for multi-stage app with kargo pipeline](https://backstage.demo.kubrix.cloud/create/templates/default/multi-stage-app-with-kargo-pipeline) you can automatically create such a repo with the predefined example application 'podtato-head'.

![app-onboarding-1](https://github.com/user-attachments/assets/cb72d622-9729-40d6-a9a6-dec7e8534d4b)

Just specifiy your application name and a description and be sure that the "FQDN" points to `demo.kubrix.cloud`. Then click 'Next'.

![app-onboarding-2](https://github.com/user-attachments/assets/0be48c9d-c748-493d-abfc-c91c3546430e)

The Git-Repo for your applications Kubernetes resources is automatically set, just click 'Next'.

![app-onboarding-3](https://github.com/user-attachments/assets/389ae3e1-7b47-48a1-957f-a0532f99c29d)

On the summary page review your data and click on 'Create'

![app-onboarding-4](https://github.com/user-attachments/assets/101f6c5f-4b02-48e2-a8b7-e64843999a0d)

Backstage now creates a new Git-Repo with the needed Helm-Chart in it and registers this new app in backstage. With 'Repository' you can open the Git-Repository and with 'Open in catalog' you will open the corresponding application component in backstage.

![app-onboarding-5](https://github.com/user-attachments/assets/c47d690b-8dac-4213-a06a-09fc51dd2ea1)

In the backstage component overview of your application you can see the ArgoCD sync and health status. It may take a few seconds until your app is recognized bei the ArgoCD ApplicationSet and synced in ArgoCD. You can click on the application name to open the corresponding argocd dashboard.

![app-onboarding-6](https://github.com/user-attachments/assets/f74e706c-bfd7-4d65-a05b-bb372ef643c5)

On the bottom of the component overview page you can see that this application has three subcomponents, one per stage.
You can click on each subcomponent and get to the overview page of each subcomponent.

![app-onboarding-7](https://github.com/user-attachments/assets/d1b9cd65-27dd-40bd-9fef-9432cb8f4cd4)

Each component page has different tabs for different informations.

![app-onboarding-8](https://github.com/user-attachments/assets/8a62d4a0-d2cf-485d-9436-f2ca998b2878)

* Overview: some key informations for your app from different tools and links to e.g. interesting Grafana Dashboards
* Kargo: GitOps-Promotion tool to bring your changes from dev to prod (Password in demo env: 'admin')

![app-onboarding-10](https://github.com/user-attachments/assets/fa9202b0-e144-41f5-8cd2-3a566defae20)

* Kubernetes: shows your app specific resources and state in your Kubernetes cluster
* Docs: shows your application documentation
* Pull Requests: Pull Requests of your application gitops-Repo
* Github issues: Issues of your application gitops-Repo
* Github Insights: overview of your application gitops-Repo
* Grafana Dashboard: overview of your application resource consumption and health state (User: admin, Password: prom-operator)

![app-onboarding-12](https://github.com/user-attachments/assets/6ce30d00-297c-4837-93d1-2ee724f15f9b)

And at the bottom of your components overview page, you see the ArgoCD status and a link to open your application.

![app-onboarding-9](https://github.com/user-attachments/assets/d23b4445-a2d3-43b5-98d6-fe81c34f87e1)

![app-onboarding-11](https://github.com/user-attachments/assets/507ed727-a8bc-4121-94d2-7f72ddf57585)


# New apps via Team-App-Of-Apps Repo

Experienced teams can create their own ArgoCD application definition or AppSets in their Team-App-Of-Apps repo created in the "Onboarding Team" step.
This application definition can point to any GitOps-Repo as long as

* ArgoCD is able to read this repo
* it meets the 'sourceRepos' rules in the [team-onboarding values](https://github.com/kubriX-demo/kubriX-demo/blob/main/platform-apps/charts/team-onboarding/values-demo-metalstack.yaml)

Please be aware that depending on the ArgoCD project definition it is very likely that your team can only deploy namespace-scoped resources in namespaces beginning with your team name (e.g. 'team-1-app-1').


# Additional infos

Some background information can also be found in the 'Additional infos' chapter.
