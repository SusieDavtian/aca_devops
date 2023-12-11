#!/bin/bash

# Set your AWS region
AWS_REGION="us-east-1"

# Specify the instance ID to keep running
INSTANCE_TO_KEEP="i-0a14aafc09f2fbaf0"

# List all running EC2 instances
echo "Listing running EC2 instances..."
aws ec2 describe-instances --region $AWS_REGION --filters Name=instance-state-name,Values=running --query 'Reservations[*].Instances[*].[InstanceId,Tags[?Key==`Name`].Value|[0]]' --output table

# Prompt for confirmation
read -p "Do you want to terminate all running EC2 instances except for the specified instance? (y/n): " CONFIRM
if [ "$CONFIRM" != "y" ]; then
    echo "Cleanup aborted."
    exit 1
fi

# Terminate all running EC2 instances except the specified one
echo "Terminating EC2 instances..."
INSTANCE_IDS=$(aws ec2 describe-instances --region $AWS_REGION --filters Name=instance-state-name,Values=running --query 'Reservations[*].Instances[*].InstanceId' --output text | grep -v $INSTANCE_TO_KEEP)
if [ -n "$INSTANCE_IDS" ]; then
    aws ec2 terminate-instances --region $AWS_REGION --instance-ids $INSTANCE_IDS
    echo "Termination initiated. Please check the AWS Console for termination status."
else
    echo "No instances to terminate except the specified one."
fi

echo "Cleanup script completed."

