#!/bin/sh

# Report space and mem metrics to AWS
/etc/cloudwatch/aws-scripts-mon/mon-put-instance-data.pl --mem-avail --disk-space-avail --disk-path=/etc/hosts --from-cron > /var/log/cloudwatch.log 2>&1

if [ -n "$ENABLE_SNS_REPORTING" ]; then
      # Report low disk space directly to SNS. Follows CloudWatch Alarm JSON format for the SNS Message field
    disk_space_avail=$(df -m /etc/hosts | awk '{print $4}' | tail -1)
    alarm_description="$disk_space_avail"MB

    if [ $disk_space_avail -lt $DISK_SPACE_AVAIL_THRESHOLD ]; then
      message="{ \
        \"AlarmName\": \"$ALARM_NAME\", \
        \"NewStateValue\": \"ALARM\", \
        \"NewStateReason\": \"Disk space available is lower than the threshold of $DISK_SPACE_AVAIL_THRESHOLD MB.\", \
        \"AlarmDescription\": \"There is only <b>$alarm_description</b> disk space available on instance <b>$INSTANCE_ID</b> \
            in cluster <b>$ECS_CLUSTER</b>. Containers running on this instance may be affected if the disk space runs out.\" \
      }"

      aws sns publish --topic-arn $SNS_TOPIC_ARN --message "$message"
    fi
fi
