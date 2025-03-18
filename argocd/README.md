## Pre-Requisites

Note that you have to deploy the following components prior to deploying this ArgoCD helm chart:

- ExternalDNS with IRSA
- Nginx Ingress Controller
- Cert-Manager + ClusterIssuer

You may refer to ```ingress-externaldns-certmanager``` to deploy the following beforehand.

## Deploying your ArgoCD Helm Chart

Refer to ```init.sh``` for deployment details.

## For First Time Login to Argo Server UI

Username: ```admin```
Password: (Refer to command below to retrieve the randomly generated password)

```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```