echo "Installing Karpenter..."

echo "cluster name: ${CLUSTER_NAME}"
echo "cluster endpoint: ${CLUSTER_ENDPOINT}"
echo "karpenter controller role arn: ${KARPENTER_CONTROLLER_ROLE_ARN}"
echo "karpenter node role arn: ${KARPENTER_NODE_ROLE_ARN}"
echo "karpenter node role name: ${KARPENTER_NODE_ROLE_NAME}"
echo "karpenter node instance profile name: ${KARPENTER_NODE_INSTANCE_PROFILE_NAME}"
echo "karpenter sqs queue: ${KARPENTER_SQS_QUEUE_NAME}"

export KARPENTER_NAMESPACE="kube-system"
export KARPENTER_VERSION="1.3.3"

helm repo add karpenter https://charts.karpenter.sh

helm repo update

# ### FOR INITIAL INSTALLATION ONLY ###
# helm template karpenter oci://public.ecr.aws/karpenter/karpenter --version "${KARPENTER_VERSION}" --namespace "${KARPENTER_NAMESPACE}" \
#     --set "settings.aws.defaultInstanceProfile=${KARPENTER_NODE_INSTANCE_PROFILE_NAME}" \
#     --set "settings.clusterName=${CLUSTER_NAME}" \
#     --set "settings.interruptionQueue=${KARPENTER_SQS_QUEUE_NAME}" \
#     --set "serviceAccount.annotations.eks\.amazonaws\.com/role-arn=${KARPENTER_CONTROLLER_ROLE_ARN}" \
#     --set controller.resources.requests.cpu=1 \
#     --set controller.resources.requests.memory=1Gi \
#     --set controller.resources.limits.cpu=1 \
#     --set controller.resources.limits.memory=1Gi > karpenter.yaml

# helm registry logout public.ecr.aws
helm upgrade --install karpenter oci://public.ecr.aws/karpenter/karpenter --version "${KARPENTER_VERSION}" \
  --namespace "${KARPENTER_NAMESPACE}" --create-namespace \
  --set serviceAccount.annotations."eks\.amazonaws\.com/role-arn"=${KARPENTER_CONTROLLER_ROLE_ARN} \
  --set settings.clusterName=${CLUSTER_NAME} \
  --set settings.clusterEndpoint=${CLUSTER_ENDPOINT} \
  --set settings.featureGates.spotToSpotConsolidation=true \
  --set settings.interruptionQueue=${CLUSTER_NAME} \
  --set controller.resources.requests.cpu=1 \
  --set controller.resources.requests.memory=1Gi \
  --set controller.resources.limits.cpu=1 \
  --set controller.resources.limits.memory=1Gi
  
# helm uninstall karpenter --namespace "${KARPENTER_NAMESPACE}"