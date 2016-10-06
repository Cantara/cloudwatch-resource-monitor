#!/bin/sh

if [ -n "$ENABLE_SNS_REPORTING" ]; then
    # Ensure these env variables are set
    : "${AWS_ACCESS_KEY_ID?Need to set AWS_ACCESS_KEY_ID}"
    : "${AWS_SECRET_ACCESS_KEY?Need to set AWS_SECRET_ACCESS_KEY}"
    : "${AWS_DEFAULT_REGION?Need to set AWS_DEFAULT_REGION}"
    : "${DISK_SPACE_AVAIL_THRESHOLD?Need to set DISK_SPACE_AVAIL_THRESHOLD}"
    : "${SNS_TOPIC_ARN?Need to set SNS_TOPIC_ARN}"

    export INSTANCE_ID=$(wget -T 5 -qO- http://169.254.169.254/latest/meta-data/instance-id)

    # Find which cluster this container instance is part of
    clusters=$(aws ecs list-clusters --query 'clusterArns[*]' --output=text)
    for cluster in $clusters
    do
        instance_arns=$(aws ecs list-container-instances --cluster $cluster --query "containerInstanceArns[*]" --output=text)
        if [ -n "$instance_arns" ]; then
            instance=$(aws ecs describe-container-instances --container-instances $instance_arns --cluster $cluster --query 'containerInstances[?ec2InstanceId==`'"$INSTANCE_ID"'`]' --output=text)
            if [ -n "$instance" ]; then
                export ECS_CLUSTER=$cluster
                break
            fi
        fi
    done

    if [ -z "$ALARM_NAME" ]; then
        export ALARM_NAME="awsecs-$INSTANCE_ID-Low-Disk-Space"
    fi
fi

echo AWSAccessKeyId=$AWS_ACCESS_KEY_ID > $HOME/aws-scripts-mon/awscreds.conf
echo AWSSecretKey=$AWS_SECRET_ACCESS_KEY >> $HOME/aws-scripts-mon/awscreds.conf

crond -f -d 0