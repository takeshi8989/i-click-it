import boto3
import os


def lambda_handler(event, context):
    ec2 = boto3.client('ec2')
    instance_id = os.environ['EC2_INSTANCE_ID']

    ec2.start_instances(InstanceIds=[instance_id])
    print(f'Started EC2 instance: {instance_id}')
    return {
        'statusCode': 200,
        'body': f'Started EC2 instance: {instance_id}'
    }
