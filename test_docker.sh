#!/bin/bash

set -e

docker build -t cloudwatch-monitor .

docker run -it \
    -e AWS_ACCESS_KEY_ID=xxxx \
    -e AWS_SECRET_ACCESS_KEY=xxxx \
    -e AWS_DEFAULT_REGION=eu-west-1 \
    -e ENABLE_SNS_REPORTING=true \
    -e DISK_SPACE_AVAIL_THRESHOLD=200000 \
    -e SNS_TOPIC_ARN=arn:aws:sns:eu-west-1:xxxxx:devtest-alarms \
    --rm cloudwatch-monitor
