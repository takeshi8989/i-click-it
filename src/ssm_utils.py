import boto3
from botocore.exceptions import NoCredentialsError, PartialCredentialsError
from log_utils import print_log


def get_ssm_parameter(param_name, region='us-east-1'):
    """Retrieve a parameter from AWS SSM Parameter Store."""
    ssm = boto3.client('ssm', region_name=region)
    try:
        response = ssm.get_parameter(Name=param_name, WithDecryption=True)
        return response['Parameter']['Value']
    except (NoCredentialsError, PartialCredentialsError):
        print_log('Error fetching parameters from SSM.')
        return None
