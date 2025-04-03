helm repo add karpenter https://charts.karpenter.sh

helm repo update

# helm install karpenter karpenter/karpenter \
#   --namespace kube-system \
#   --create-namespace \
#   --version v0.28.0 \
#   --set serviceAccount.create=false \
#   --set serviceAccount.name=karpenter \
#   --set controller.clusterName=$CLUSTER_NAME \
#   --set controller.clusterEndpoint=$CLUSTER_ENDPOINT \
#   --set defaultProvisioner.provisionerName=default \
#   --set defaultProvisioner.clusterName=$CLUSTER_NAME \
#   --set defaultProvisioner.clusterEndpoint=$CLUSTER_ENDPOINT