#!/bin/sh

instanceId=i-00518a40f05afa516

clusters=$(aws ecs list-clusters --query 'clusterArns[*]' --output=text)

for cluster in $clusters
do
    echo "Searching cluster '$cluster'"
    instance_arns=$(aws ecs list-container-instances --cluster $cluster --query "containerInstanceArns[*]" --output=text)
    instance=$(aws ecs describe-container-instances --container-instances $instance_arns --cluster $cluster --query 'containerInstances[?ec2InstanceId==`'"$instanceId"'`]' --output=text)
    if [ -n "$instance" ]; then
        echo "Found '$instanceId' in cluster '$cluster'"
        export CLUSTER=$cluster
        break
    fi
done