## Pre-Requisites

Note that you have to deploy the following components prior to deploying this ArgoCD helm chart:

- Nginx Ingress Controller
- ExternalDNS with IRSA

## Deploying your ArgoCD Helm Chart

Refer to ```init.sh``` for deployment details.

## For Cluster Issuer

You will need to still substitute your email address after deploying your cert-manager chart. 

```yaml
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    email: # Replace with your email
    privateKeySecretRef:
      name: letsencrypt-prod
    solvers:
    - http01:
        ingress:
          ingressClassName: nginx
```
