<p align="center">
    <img src="https://www.logo.wine/a/logo/Kubernetes/Kubernetes-Logo.wine.svg" height="200">
</p>

<h1 align="center">The Kubernetes Project</h1>
<p align="center">by Capstone Project - CE8 Group 1</p>

<p align="center">
  <img src="https://img.shields.io/github/actions/workflow/status/ntu-ce8-project/eks-infra/cluster-creation.yml">
  <img src="https://img.shields.io/github/license/ntu-ce8-project/eks-infra">
  <img src="https://img.shields.io/github/languages/top/ntu-ce8-project/eks-infra">
  <img src="https://img.shields.io/github/repo-size/ntu-ce8-project/eks-infra">
  <img src="https://img.shields.io/github/stars/ntu-ce8-project/eks-infra">
</p>

<p align="center">
  <img src="https://img.shields.io/github/commit-activity/t/ntu-ce8-project/eks-infra">
  <img src="https://img.shields.io/github/commit-activity/w/ntu-ce8-project/eks-infra">
  <img src="https://img.shields.io/github/last-commit/ntu-ce8-project/eks-infra">
  <img src="https://img.shields.io/github/issues/ntu-ce8-project/eks-infra">
  <img src="https://img.shields.io/github/issues-closed/ntu-ce8-project/eks-infra">
</p>

<p align="center">
  <img src="https://img.shields.io/badge/kubernetes-blue?style=flat&logo=kubernetes&logoColor=white">
  <img src="https://img.shields.io/badge/aws_eks-orange?style=flat&logo=amazonwebservices">

  <img src="https://img.shields.io/badge/github_actions-grey?style=flat&logo=github">
  <img src="https://img.shields.io/badge/helm_charts-blue?style=flat&logo=helm">
  <img src="https://img.shields.io/badge/terraform-lavender?style=flat&logo=terraform">

  <img src="https://img.shields.io/badge/k6-load_tested-mediumpurple?style=flat&logo=k6">
  <img src="https://img.shields.io/badge/grafana-dashboards-orange?style=flat&logo=grafana">
</p>

## Progress

Track the progress of this project from our [issues](https://github.com/ntu-ce8-project/eks-infra/issues?q=is%3Aissue%20state%3Aclosed), [kanban](https://github.com/orgs/ntu-ce8-project/projects/2), and [milestones](https://github.com/ntu-ce8-project/eks-infra/milestones?state=closed).

## Documentation

Read our [documentation](https://github.com/ntu-ce8-project/eks-infra/wiki).

## Application architecture

This is the application architecture.

![app](./docs/diagrams/app.drawio.svg)

This is the microservice architecture of the application. See all of our beautiful [diagrams](./docs/generated-diagrams/).

![shop](./docs/generated-diagrams/shop-staging/shop-staging.png)

## Cluster architecture

This is the entire ecosystem of the cluster.

![ecosystem](./docs/generated-diagrams/ecosystem/ecosystem.png)


## Autoscaling in Kubernetes

### Karpenter

Sequence diagram of Karpenter workflow.

```mermaid
sequenceDiagram
    participant U as User
    participant WF as GitHub Workflow
    participant CC as create-cluster Job
    participant KP as Karpenter Job
    participant AWS as AWS Services

    U->>WF: Trigger workflow (with Karpenter input)
    WF->>CC: Run create-cluster job
    CC->>AWS: Provision cluster and retrieve Karpenter config
    WF-->>KP: Invoke Karpenter job (conditional)
    KP->>AWS: Deploy Karpenter autoscaler
    AWS-->>KP: Confirm deployment
```

### Horizontal Pod Autoscaler (HPA)

![image](https://github.com/user-attachments/assets/84d43ea7-61c0-4eca-aacf-6ab5191398f0)

## Contributors

To contribute to the repository, follow our [contribution guidelines](/CONTRIBUTING.md).
