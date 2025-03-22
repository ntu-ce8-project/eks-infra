## Introduction

This folder contains the required terraform files to create your AWS EKS cluster. 

## Usage

You may ```terraform apply``` the files as it is, however you may refer to the comments in the TF files for guidance as well.

You may also create the ExternalDNS resources (IAM Role for Service Account) & Loki Resources (Buckets & IAM Role for Service Account) based on the boolean flags below: 

```hcl
# Set to true if you're making use of ExternalDNS with Route53
variable "enable_external_dns" {
  type    = bool
  default = true
}

# Set to true if you're making use of Loki with a s3 backend
variable "enable_loki_s3" {
  type    = bool
  default = true
}

# Set to true if you're making use of a PersistentVolume with EBS CSI Driver Add-ons
variable "enable_ebs_csi_driver_role" {
  type    = bool
  default = true
}
```

All of the related IRSA resources are stored in ```irsa.tf``

## For Cilium Setup Only

If you're looking to create a kube proxy free eks cluster, you may do the following:

1) Comment out the node groups first as cilium has to be installed for the node groups to turn healthy
2) comment out node group > tf apply > axe it halfways since coredns pods dont turn healthy > install cilium > tf apply

```bash
helm install cilium cilium/cilium --version 1.16.7 \
  --namespace kube-system \
  --set eni.enabled=true \
  --set ipam.mode=eni \
  --set egressMasqueradeInterfaces=eth0 \
  --set routingMode=native \
  --set k8sServiceHost=7505637818EB91FC48302ED9CB5BA64D.gr7.ap-southeast-1.eks.amazonaws.com \
  --set k8sServicePort=443 \
  --set kubeProxyReplacement=true
```
