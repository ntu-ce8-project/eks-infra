#!/bin/bash

# Customize these values:
tag_key="Name"
tag_value="ce8-g1-capstone-vpc"

# Lookup VPC by tag
vpc=$(aws ec2 describe-vpcs \
  --filters "Name=tag:$tag_key,Values=$tag_value" \
  --query "Vpcs[0].VpcId" --output text)

# Check if VPC was found
if [[ "$vpc" == "None" || -z "$vpc" ]]; then
  echo "VPC not found with tag $tag_key=$tag_value"
  exit 1
fi

echo "Found VPC ID: $vpc"

timestamp=$(date +"%Y-%m-%d_%H-%M-%S")
outfile="vpc_inventory_$vpc_$timestamp.txt"

echo "Generating VPC resource inventory for: $vpc"
echo "Saving to: $outfile"
echo "========== VPC Resource Inventory - $vpc ==========" > "$outfile"

# Function to append and format
log() {
  echo -e "\n==== $1 ====" >> "$outfile"
  shift
  "$@" >> "$outfile" 2>&1
}

# ELB (Classic)
log "Classic ELBs" \
  aws elb describe-load-balancers \
    --query "LoadBalancerDescriptions[?VPCId=='$vpc'].[LoadBalancerName,DNSName]" \
    --output table

# ELBv2 (ALB/NLB)
log "Application/Network Load Balancers" \
  aws elbv2 describe-load-balancers \
    --query "LoadBalancers[?VpcId=='$vpc'].[LoadBalancerName,DNSName,LoadBalancerArn]" \
    --output table

# Target Groups
log "Target Groups" \
  aws elbv2 describe-target-groups \
    --query "TargetGroups[?VpcId=='$vpc'].[TargetGroupName,TargetGroupArn]" \
    --output table

# ElastiCache
log "ElastiCache Clusters" \
  aws elasticache describe-cache-clusters \
    --query "CacheClusters[?VpcId=='$vpc'].[CacheClusterId,Engine,CacheNodeType]" \
    --output table

# DMS
log "DMS Replication Instances" \
  aws dms describe-replication-instances \
    --query "ReplicationInstances[?ReplicationInstanceVpcId=='$vpc'].[ReplicationInstanceIdentifier,ReplicationInstanceArn]" \
    --output table

# NAT Gateways
log "NAT Gateways" \
  aws ec2 describe-nat-gateways --filter "Name=vpc-id,Values=$vpc" \
    --query "NatGateways[*].[NatGatewayId,State,SubnetId]" --output table

# Internet Gateways
log "Internet Gateways" \
  aws ec2 describe-internet-gateways --filters "Name=attachment.vpc-id,Values=$vpc" \
    --query "InternetGateways[*].[InternetGatewayId]" --output table

# VPC Endpoints
log "VPC Endpoints" \
  aws ec2 describe-vpc-endpoints --filters "Name=vpc-id,Values=$vpc" \
    --query "VpcEndpoints[*].[VpcEndpointId,ServiceName]" --output table

# VPC Peering Connections
log "VPC Peering Connections" \
  aws ec2 describe-vpc-peering-connections --filters "Name=requester-vpc-info.vpc-id,Values=$vpc" \
    --query "VpcPeeringConnections[*].[VpcPeeringConnectionId,Status.Code]" --output table

# VPN Connections & Gateways
log "VPN Connections" \
  aws ec2 describe-vpn-connections --filters "Name=vpc-id,Values=$vpc" \
    --query "VpnConnections[*].[VpnConnectionId,State]" --output table

log "VPN Gateways" \
  aws ec2 describe-vpn-gateways --filters "Name=attachment.vpc-id,Values=$vpc" \
    --query "VpnGateways[*].[VpnGatewayId,State]" --output table

# Network Interfaces
log "Network Interfaces" \
  aws ec2 describe-network-interfaces --filters "Name=vpc-id,Values=$vpc" \
    --query "NetworkInterfaces[*].[NetworkInterfaceId,Status,Description]" --output table

# EC2 Instances
log "EC2 Instances" \
  aws ec2 describe-instances --filters "Name=vpc-id,Values=$vpc" \
    --query "Reservations[*].Instances[*].[InstanceId,State.Name,InstanceType,PrivateIpAddress]" --output table

# Security Groups
log "Security Groups" \
  aws ec2 describe-security-groups --filters "Name=vpc-id,Values=$vpc" \
    --query "SecurityGroups[*].[GroupId,GroupName]" --output table

# Network ACLs
log "Network ACLs" \
  aws ec2 describe-network-acls --filters "Name=vpc-id,Values=$vpc" \
    --query "NetworkAcls[*].[NetworkAclId,IsDefault]" --output table

# Route Tables
log "Route Tables" \
  aws ec2 describe-route-tables --filters "Name=vpc-id,Values=$vpc" \
    --query "RouteTables[*].[RouteTableId]" --output table

# Subnets
log "Subnets" \
  aws ec2 describe-subnets --filters "Name=vpc-id,Values=$vpc" \
    --query "Subnets[*].[SubnetId,CidrBlock,AvailabilityZone]" --output table

# Final message
echo -e "\nInventory complete. Saved to: $outfile"