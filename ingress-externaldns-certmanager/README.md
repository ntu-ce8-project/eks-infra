## Creating EKS Cluster and Updating Helm values

Go to ``` terraform-learner-cluster```  & run ``` terraform apply``` . However remember to set the following variable to true, in order to create your ExternalDNS IAM Role for your ExternalDNS service later.

```hcl
variable "enable_external_dns" {
  type    = bool
  default = true
}
```
Remember to get the ```  ARN of your ExternalDNS Role``` & Update the file in ```helm-values/external-dns-values.yaml``` with the value of your ARN.


```yaml
provider:
  name: aws
serviceAccount:
  annotations:
    eks.amazonaws.com/role-arn: # The external-dns role ARN
env:
  - name: AWS_DEFAULT_REGION
    value: ap-southeast-1 # change to region where EKS is installed
```

## Bootstrap your cluster with the required helm charts

You will be deploying the following helm charts for your cluster:

- Nginx Ingress Controller
- ExternalDNS
- Cert-Manager

You can refer to the ```init.sh``` script to run the required helm commands:

```bash 

#!/usr/bin/env bash

helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo add external-dns https://kubernetes-sigs.github.io/external-dns/
helm repo add jetstack https://charts.jetstack.io

helm repo update

helm upgrade --install ingress-nginx ingress-nginx/ingress-nginx \
  --namespace ingress-nginx \
  --create-namespace

helm upgrade --install external-dns external-dns/external-dns \
  --namespace external-dns \
  --create-namespace \
  --values helm-values/external-dns-values.yaml

helm upgrade --install cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --version v1.17.0 \
  --set crds.enabled=true
```

Once you've ran the script, run the following commands to verify that your pods & services are deployed.

```bash 
kubectl get pods,svc -n ingress-nginx
kubectl get pods,svc -n cert-manager
kubectl get pods,svc -n external-dns
```
## Deploying the ClusterIssuer

Deploy the manifest file ```cert-manager-cluster-issuer/cluster-issuer.yaml``` and add the details below.

```yaml
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    email: jazeel.meerasah@gmail.com  # Replace with your email
    privateKeySecretRef:
      name: letsencrypt-prod
    solvers:
    - http01:
        ingress:
          class: nginx
```

## Deploying your Service & Deployments

You may deploy the ```deployment-manifests/deployment.yaml``` & ```deployment-manifests/service.yaml``` files accordingly. Remember to update the naming (such as namespace) if required. 

Ensure that your service is working prior to proceeding with the next step

```bash 
kubectl port-forward service/${SERVICE_NAME} 9090:80
```

## Creating a Ingress Resource with ExternalDNS & Nginx Controller

```yaml
  apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: #Ingress Resource name
  namespace: #Your namespace for your deployment and service
  annotations:
    external-dns.alpha.kubernetes.io/hostname: # Replace with your domain
spec:
  ingressClassName: nginx
  rules:
  - host:  # Replace with your domain
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: #Service name
            port:
              number: 80

```

This would create a Route53 A record to point to your Load Balancer, which was created as a result of your Ingress Controller above.

curl to ensure that your domain is able to route traffic to your service

## Enable LetsEncrypt TLS cert on your Ingress


