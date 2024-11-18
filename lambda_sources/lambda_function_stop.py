import boto3
import os


def lambda_handler(event, context):
    ec2 = boto3.client('ec2')
    instance_id = os.environ['EC2_INSTANCE_ID']

    ec2.stop_instances(InstanceIds=[instance_id])
    print(f'Stopped EC2 instance: {instance_id}')
    return {
        'statusCode': 200,
        'body': f'Stopped EC2 instance: {instance_id}'
    }
