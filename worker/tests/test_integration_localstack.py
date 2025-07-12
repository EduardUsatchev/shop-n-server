import os
import json
import boto3
import pytest

@pytest.fixture(scope="module")
def setup_queue():
    os.environ["AWS_REGION"] = "eu-west-1"
    os.environ["SQS_QUEUE_URL"] = "http://localhost:4566/000000000000/orders-queue"
    os.environ["AWS_ENDPOINT_URL"] = "http://localhost:4566"
    os.environ["AWS_ACCESS_KEY_ID"] = "dummy"
    os.environ["AWS_SECRET_ACCESS_KEY"] = "dummy"

    # Explicitly set region_name!
    sqs = boto3.client(
        "sqs",
        region_name=os.environ["AWS_REGION"],    # <---- this line fixes the bug!
        endpoint_url=os.environ["AWS_ENDPOINT_URL"],
        aws_access_key_id=os.environ["AWS_ACCESS_KEY_ID"],
        aws_secret_access_key=os.environ["AWS_SECRET_ACCESS_KEY"]
    )
    queue_url = os.environ["SQS_QUEUE_URL"]
    yield sqs, queue_url

def test_integration_enqueue(setup_queue):
    sqs, queue_url = setup_queue
    msg_body = json.dumps({"id": "test-123"})
    sqs.send_message(QueueUrl=queue_url, MessageBody=msg_body)
    msgs = sqs.receive_message(QueueUrl=queue_url, MaxNumberOfMessages=1, WaitTimeSeconds=2)
    assert "Messages" in msgs
    assert json.loads(msgs["Messages"][0]["Body"])["id"] == "test-123"
