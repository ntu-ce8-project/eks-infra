## Creating EKS Cluster

Go to ``` terraform-learner-cluster```  & run ``` terraform apply``` . However remember to set the following variable to true, in order to create your ExternalDNS IAM Role for your ExternalDNS service later.

```hcl
variable "enable_external_dns" {
  type    = bool
  default = true
}
```
Remember to get the ```  ARN of your ExternalDNS Role```

## Deploying your Service & Deployments

You may deploy the ```deployment.yaml``` & ```service.yaml``` files accordingly. Remember to update the naming (such as namespace) if required. 

## Deploying your Nginx Ingress Controller

```bash 
helm upgrade --install ingress-nginx ingress-nginx --repo https://kubernetes.github.io/ingress-nginx --namespace ingress-nginx --create-namespace

kubectl get pods,svc -n ingress-nginx
``` 

## Deploying ExternalDNS

Remember to substitute the  ```  ARN of your ExternalDNS Role``` in your ```external-dns-values.yaml``` file.

```yaml 
provider:
  name: aws
serviceAccount:
  annotations:
    eks.amazonaws.com/role-arn:   #external-dns role
env:
  - name: AWS_DEFAULT_REGION
    value: ap-southeast-1 # change to region where EKS is installed
```
```bash 
helm repo add external-dns https://kubernetes-sigs.github.io/external-dns/

helm upgrade --install external-dns external-dns/external-dns --namespace external-dns --create-namespace --values external-dns-values.yaml

kubectl get pods,svc -n external-dns
``` 

The above would grant ExternalDNS the permissions required to create a record in your Route53 Hosted Zone for your Ingress resource.

## Creating a Ingress Resource with ExternalDNS & Nginx Controller

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: your-ingress #Ingress Name
  namespace: your-namespace #Namespace to deploy your Ingress in
  annotations:
    external-dns.alpha.kubernetes.io/hostname: "something.example.com" # Replace with your domain
spec:
  ingressClassName: nginx
  rules:
  - host: "something.example.com" # Replace with your domain
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: your-service-name
            port:
              number: 80
```

This would create a Route53 A record to point to your Load Balancer, which was created as a result of your Ingress Controller above.

## Deploying cert-manager with LetsEncrypt for TLS.

This is to enable HTTPS on your Ingress Resource.

```bash 
helm repo add jetstack https://charts.jetstack.io

helm install \
  cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --version v1.17.0 \
  --set crds.enabled=true

kubectl get pods -n cert-manager
``` 

Create a file called ```cluster-issuer.yaml``` and add the details below.

```yaml
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    email:  # Replace with your email
    privateKeySecretRef:
      name: letsencrypt-prod
    solvers:
    - http01:
        ingress:
          class: nginx
```

```bash
kubectl apply -f cluster-issuer.yaml
```

## Update your Ingress to use Cert-Manager

Add the following blocks to your Ingress resource and redeploy.

```yaml
  annotations:
    cert-manager.io/cluster-issuer: "letsencrypt-prod"
spec:
  ingressClassName: nginx
  tls:
    - hosts:
        - "something.example.com" # Replace with your domain
      secretName: your-tls-secret
```
