#!/bin/bash

# This script deletes all resources in a specified VPC in AWS.
# You may need to run this script a couple of times to get it to completely delete everything.

# Find VPC ID based on tag
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

echo "Deleting resources in VPC: $vpc"

echo "Deleting Classic ELBs in VPC: $vpc"
for elb in $(aws elb describe-load-balancers \
    --query 'LoadBalancerDescriptions[?VPCId==`'"$vpc"'`].LoadBalancerName' --output text); do
  echo "Deleting Classic ELB: $elb"
  aws elb delete-load-balancer --load-balancer-name "$elb"
done

echo "Deleting ALB/NLB (ELBv2) in VPC: $vpc"
for alb in $(aws elbv2 describe-load-balancers \
    --query 'LoadBalancers[?VpcId==`'"$vpc"'`].LoadBalancerArn' --output text); do
  echo "Deleting ELBv2: $alb"
  aws elbv2 delete-load-balancer --load-balancer-arn "$alb"
done

echo "Deleting resources in VPC: $vpc"

# Detach and delete Internet Gateway
for igw in $(aws ec2 describe-internet-gateways --filters "Name=attachment.vpc-id,Values=$vpc" --query 'InternetGateways[*].InternetGatewayId' --output text); do
  echo "Detaching and deleting Internet Gateway: $igw"
  aws ec2 detach-internet-gateway --internet-gateway-id $igw --vpc-id $vpc
  aws ec2 delete-internet-gateway --internet-gateway-id $igw
done

# Delete NAT Gateways
for nat in $(aws ec2 describe-nat-gateways --filter "Name=vpc-id,Values=$vpc" --query 'NatGateways[*].NatGatewayId' --output text); do
  echo "Deleting NAT Gateway: $nat"
  aws ec2 delete-nat-gateway --nat-gateway-id $nat
done

# Delete VPC Endpoints
for endpoint in $(aws ec2 describe-vpc-endpoints --filters "Name=vpc-id,Values=$vpc" --query 'VpcEndpoints[*].VpcEndpointId' --output text); do
  echo "Deleting VPC Endpoint: $endpoint"
  aws ec2 delete-vpc-endpoints --vpc-endpoint-ids $endpoint
done

# Delete VPC Peering Connections
for peer in $(aws ec2 describe-vpc-peering-connections --filters "Name=requester-vpc-info.vpc-id,Values=$vpc" --query 'VpcPeeringConnections[*].VpcPeeringConnectionId' --output text); do
  echo "Deleting VPC Peering Connection: $peer"
  aws ec2 delete-vpc-peering-connection --vpc-peering-connection-id $peer
done

# Delete VPN Connections
for vpn in $(aws ec2 describe-vpn-connections --filters "Name=vpc-id,Values=$vpc" --query 'VpnConnections[*].VpnConnectionId' --output text); do
  echo "Deleting VPN Connection: $vpn"
  aws ec2 delete-vpn-connection --vpn-connection-id $vpn
done

# Delete VPN Gateways (after detaching)
for vgw in $(aws ec2 describe-vpn-gateways --filters "Name=attachment.vpc-id,Values=$vpc" --query 'VpnGateways[*].VpnGatewayId' --output text); do
  echo "Detaching and deleting VPN Gateway: $vgw"
  aws ec2 detach-vpn-gateway --vpn-gateway-id $vgw --vpc-id $vpc
  aws ec2 delete-vpn-gateway --vpn-gateway-id $vgw
done

# Delete network interfaces
for eni in $(aws ec2 describe-network-interfaces --filters "Name=vpc-id,Values=$vpc" --query 'NetworkInterfaces[*].NetworkInterfaceId' --output text); do
  echo "Deleting Network Interface: $eni"
  aws ec2 delete-network-interface --network-interface-id $eni
done

# Terminate EC2 instances
for instance in $(aws ec2 describe-instances --filters "Name=vpc-id,Values=$vpc" --query 'Reservations[*].Instances[*].InstanceId' --output text); do
  echo "Terminating Instance: $instance"
  aws ec2 terminate-instances --instance-ids $instance
done

# Delete Security Groups (except default)
for sg in $(aws ec2 describe-security-groups --filters "Name=vpc-id,Values=$vpc" --query 'SecurityGroups[?GroupName!=`default`].GroupId' --output text); do
  echo "Deleting Security Group: $sg"
  aws ec2 delete-security-group --group-id $sg
done

# Delete Network ACLs (except default)
for acl in $(aws ec2 describe-network-acls --filters "Name=vpc-id,Values=$vpc" --query 'NetworkAcls[?IsDefault==`false`].NetworkAclId' --output text); do
  echo "Deleting Network ACL: $acl"
  aws ec2 delete-network-acl --network-acl-id $acl
done

# Delete Route Tables (except main)
for rt in $(aws ec2 describe-route-tables --filters "Name=vpc-id,Values=$vpc" --query 'RouteTables[?Associations[?Main!=`true`]].RouteTableId' --output text); do
  echo "Deleting Route Table: $rt"
  aws ec2 delete-route-table --route-table-id $rt
done

# Delete Subnets
for subnet in $(aws ec2 describe-subnets --filters "Name=vpc-id,Values=$vpc" --query 'Subnets[*].SubnetId' --output text); do
  echo "Deleting Subnet: $subnet"
  aws ec2 delete-subnet --subnet-id $subnet
done

# Finally, delete the VPC
echo "Deleting VPC: $vpc"
aws ec2 delete-vpc --vpc-id $vpc