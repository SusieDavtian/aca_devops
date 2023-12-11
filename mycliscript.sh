#!/bin/bash

# My Values
AWS_REGION="us-east-1"
VPC_ID="vpc-07e6017e17bc072bb"
SUBNET_ID="subnet-0fe01b7600ca78f77"
INTERNET_GATEWAY_ID="igw-0ccbca4be4dceef41"
ROUTE_TABLE_ID="rtb-01c6e91273b756584"
KEY_PAIR_NAME="mynewapp"

# 1. Create VPC
vpc_id=$(aws ec2 create-vpc --cidr-block 10.0.0.0/16 --region "$AWS_REGION" --query 'Vpc.VpcId' --output json)

# 2. Create Internet Gateway
internet_gateway_id=$(aws ec2 create-internet-gateway --region "$AWS_REGION" --query 'InternetGateway.InternetGatewayId' --output json)

# 3. Attach Internet Gateway to VPC
aws ec2 attach-internet-gateway --internet-gateway-id "$internet_gateway_id" --vpc-id "$vpc_id" --region "$AWS_REGION" --output json

# 4. Create Subnet
subnet_id=$(aws ec2 create-subnet --vpc-id "$vpc_id" --cidr-block 10.0.0.0/24 --region "$AWS_REGION" --query 'Subnet.SubnetId' --output json)

# 5. Create Route Table
route_table_id=$(aws ec2 create-route-table --vpc-id "$vpc_id" --region "$AWS_REGION" --query 'RouteTable.RouteTableId' --output json)

# 6. Create Route for Internet Gateway in Route Table
aws ec2 create-route --route-table-id "$route_table_id" --destination-cidr-block 0.0.0.0/0 --gateway-id "$internet_gateway_id" --region "$AWS_REGION" --output json

# 7. Associate Subnet with Route Table
aws ec2 associate-route-table --subnet-id "$subnet_id" --route-table-id "$route_table_id" --region "$AWS_REGION" --output json

# Launch an EC2 instance
aws ec2 run-instances \
  --image-id ami-0e35da80743b7a307 \
  --instance-type t2.micro \
  --key-name "$KEY_PAIR_NAME" \
  --subnet-id "$subnet_id" \
  --region "$AWS_REGION" \

echo "My script is working! EC2 instance launched."

