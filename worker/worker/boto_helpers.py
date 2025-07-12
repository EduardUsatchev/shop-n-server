import os
import boto3

def make_boto3_client(service, **kwargs):
    # Defaults for LocalStack/dev
    return boto3.client(
        service,
        region_name=os.getenv("AWS_REGION", "eu-west-1"),
        endpoint_url=os.getenv("AWS_ENDPOINT_URL"),
        aws_access_key_id=os.getenv("AWS_ACCESS_KEY_ID", "dummy"),
        aws_secret_access_key=os.getenv("AWS_SECRET_ACCESS_KEY", "dummy"),
        **kwargs
    )
