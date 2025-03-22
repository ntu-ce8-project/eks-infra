## Pre-Requisites

Note that you have to deploy the following components prior to deploying this ArgoCD helm chart:

- Nginx Ingress Controller
- ExternalDNS with IRSA
- Cert-Manager + ClusterIssuer

## Deploying your ArgoCD Helm Chart

Refer to ```init.sh``` for deployment details.

## For First Time Login to Argo Server UI

Username: ```admin```
Password: (Refer to command below to retrieve the randomly generated password)

```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```
