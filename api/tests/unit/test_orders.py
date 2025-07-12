import pytest
from flask import Flask
from app.orders import orders_bp

@pytest.fixture
def client(monkeypatch):
    # Ensure required environment variables are set for the Config class
    monkeypatch.setenv("AWS_REGION", "eu-west-1")
    monkeypatch.setenv("SQS_QUEUE_URL", "http://localhost:4566/000000000000/orders-queue")
    app = Flask(__name__)
    app.register_blueprint(orders_bp)
    client = app.test_client()

    class DummySQS:
        def send_message(self, QueueUrl, MessageBody): pass

    # Patch boto3.client to use DummySQS
    monkeypatch.setattr("app.orders.boto3.client", lambda *a, **k: DummySQS())
    return client

def test_create_order(client):
    resp = client.post("/orders", json={"id": "1"})
    assert resp.status_code == 202
    data = resp.get_json()
    assert data["status"] == "queued"
