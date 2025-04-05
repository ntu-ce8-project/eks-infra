echo "Installing Karpenter..."

echo "cluster name: ${CLUSTER_NAME}"
echo "cluster endpoint: ${CLUSTER_ENDPOINT}"
echo "karpenter controller role arn: ${KARPENTER_CONTROLLER_ROLE_ARN}"
echo "karpenter node role arn: ${KARPENTER_NODE_ROLE_ARN}"
echo "karpenter node role name: ${KARPENTER_NODE_ROLE_NAME}"


export KARPENTER_NAMESPACE="kube-system"
export KARPENTER_VERSION="1.3.3"

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