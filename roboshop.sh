#!/bin/bash

AMI_ID="ami-09c813fb71547fc4f"
SG_ID="sg-092003eb4d02ae0a1"

for instance in $@
do
    instance_id=$(aws ec2 run-instances --image-id ami-09c813fb71547fc4f --instance-type t3.micro --security-group-ids sg-092003eb4d02ae0a1 --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=Test}]' --query 'Instances[0].InstanceId' --output tex)

    #### get the private ip of the instance
    if [ $instance != "frantend" ] ; then
        IP=$(aws ec2 run-instances --image-id ami-09c813fb71547fc4f --instance-type t3.micro --security-group-ids sg-092003eb4d02ae0a1 --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=Test}]' --query 'Reservations[0].Instances[0].PrivateIpAddress' --output text)
    else
        IP=$(aws ec2 describe-instances --instance-ids i-0933e74e71efac753 --query 'Reservations[0].Instances[0].PublicIpAddress' --output text)

    fi

    echo "$instance : $IP"
done