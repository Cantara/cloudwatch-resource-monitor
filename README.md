# CloudWatch Monitoring

A Docker setup for monitoring scripts that posts to CloudWatch. It currently only contains standard script made by Amazon and posts memory available and hard disk space available. Stats are available from CloudWatch under Metrics -> Linux System Metrics.

## Alarm reporting
The container supports posting notification to SNS when available disk space is below the threshold. It follows the same message pattern as messages from Cloudwatch Alarms to SNS, so the same lambda as alarms from CloudWatch can be used. The reason for reporting directly to SNS instead of through an CloudWatch Alarm is to avoid having to clean up alarms if running on frequently changing spot instances.

## Env variables
- __AWS_ACCESS_KEY_ID__
- __AWS_SECRET_ACCESS_KEY__
- ENABLE_SNS_REPORTING - _true/false_ - If low disk space should be reported to SNS
  - AWS_DEFAULT_REGION - the AWS region the SNS topic is in
  - DISK_SPACE_AVAIL_THRESHOLD - threshold in megabytes
  - SNS_TOPIC_ARN - SNS topic alarms will be published to


## Example structure to SNS
This is how the event object to the lambda will look like.
```
{
    EventSource: 'aws:sns',
    EventVersion: '1.0',
    EventSubscriptionArn: 'arn:aws:sns:eu-west-1:xxxxxx:aro-devtest-alarms:bd708f16-c80e-4d45-93b0-5828796631b7',
    Sns: {
        Type: 'Notification',
        MessageId: '365fdb41-bd2d-5312-beda-8b15e2f57090',
        TopicArn: 'arn:aws:sns:eu-west-1:xxxxxx:aro-devtest-alarms',
        Subject: 'ALARM: "temp-test-alarm" in EU - Ireland',
        Message: '{
          "AlarmName": "awsecs--Low-Disk-Space",
          "NewStateValue": "ALARM",
          "NewStateReason": "Disk space available is lower than the threshold of 1000 MB.",
          "AlarmDescription": "There is only <b>1000MB</b> disk space available on instance <b></b> in cluster <b></b>. Containers running on this instance may be affected if the disk space runs out."
        }',
        Timestamp: '2016-09-15T08:36:40.886Z',
        SignatureVersion: '1',
        Signature: 'xxxxxx',
        SigningCertUrl: 'https://sns.eu-west-1.amazonaws.com/SimpleNotificationService-123123.pem',
        UnsubscribeUrl: 'https://sns.eu-west-1.amazonaws.com/?Action=Unsubscribe&SubscriptionArn=arn:aws:sns:eu-west-1:xxxxxx:aro-devtest-alarms:bd708f16-c80e-4d45-93b0-5828796631b7',
        MessageAttributes: {}
    }
}
```

## Example run
See `test_docker.sh`
