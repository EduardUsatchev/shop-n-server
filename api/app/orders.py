import json
from flask import Blueprint, request, jsonify
from app.config import Config
import boto3
import os
from prometheus_client import Counter

orders_received = Counter('orders_received_total', 'Total number of orders received')


orders_bp = Blueprint("orders", __name__)

print("DEBUG AWS ENV", os.environ.get("AWS_REGION"), os.environ.get("AWS_ACCESS_KEY_ID"), os.environ.get("AWS_SECRET_ACCESS_KEY"), os.environ.get("SQS_QUEUE_URL"))

def get_sqs_client(cfg: Config):
    """Create an SQS client with the config's region, creds, and endpoint."""
    return boto3.client(
        "sqs",
        region_name=cfg.AWS_REGION,
        endpoint_url="http://localstack:4566",  # or cfg.SQS_URL.split('/000000000000/')[0] if dynamic
        aws_access_key_id=cfg.AWS_ACCESS_KEY_ID,
        aws_secret_access_key=cfg.AWS_SECRET_ACCESS_KEY,
    )


@orders_bp.route("/orders", methods=["POST"])
def create_order():
    data = request.get_json()
    cfg = Config()
    if not cfg.SQS_URL or not cfg.AWS_REGION:
        return jsonify({"error": "Missing SQS_URL or AWS_REGION"}), 500
    sqs = get_sqs_client(cfg)
    sqs.send_message(QueueUrl=cfg.SQS_URL, MessageBody=json.dumps(data))
    orders_received.inc()  # increment counter on success
    return jsonify({"status": "queued"}), 202



@orders_bp.route("/orders", methods=["POST"])
def create_order():
    data = request.get_json()
    cfg = Config()
    if not cfg.SQS_URL or not cfg.AWS_REGION:
        return jsonify({"error": "Missing SQS_URL or AWS_REGION"}), 500
    sqs = get_sqs_client(cfg)
    sqs.send_message(QueueUrl=cfg.SQS_URL, MessageBody=json.dumps(data))
    orders_received.inc()  # increment counter on success
    return jsonify({"status": "queued"}), 202
