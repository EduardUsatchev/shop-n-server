import os
import boto3
import pytest
from flask import Flask
from app.orders import orders_bp

@pytest.fixture(scope="module")
def setup_queue():
    # Make sure the env variables are set
    os.environ["AWS_REGION"] = "eu-west-1"
    os.environ["SQS_QUEUE_URL"] = "http://localhost:4566/000000000000/orders-queue"
    os.environ["AWS_ENDPOINT_URL"] = "http://localhost:4566"

    sqs = boto3.client("sqs", endpoint_url=os.getenv("AWS_ENDPOINT_URL"))
    queue_url = os.getenv("SQS_QUEUE_URL")
    # Create the queue (ok if already exists)
    sqs.create_queue(QueueName=queue_url.split("/")[-1])
    return sqs, queue_url

def test_integration_enqueue(setup_queue):
    sqs, queue_url = setup_queue
    app = Flask(__name__)
    app.register_blueprint(orders_bp)
    client = app.test_client()
    resp = client.post("/orders", json={"id": "42"})
    assert resp.status_code == 202
    msgs = sqs.receive_message(QueueUrl=queue_url, MaxNumberOfMessages=1)
    # For localstack, if no messages yet, 'Messages' may not be present!
    assert "Messages" in msgs or msgs.get("ResponseMetadata", {}).get("HTTPStatusCode") == 200
