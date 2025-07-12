import json
from flask import Blueprint, request, jsonify
from app.config import Config
import boto3

orders_bp = Blueprint("orders", __name__)

def get_sqs_client(cfg: Config):
    """Create an SQS client with the config's region."""
    return boto3.client("sqs", region_name=cfg.AWS_REGION)

@orders_bp.route("/orders", methods=["POST"])
def create_order():
    data = request.get_json()
    cfg = Config()
    # Validate config at runtime
    if not cfg.SQS_URL or not cfg.AWS_REGION:
        return jsonify({"error": "Missing SQS_URL or AWS_REGION"}), 500

    sqs = get_sqs_client(cfg)
    sqs.send_message(QueueUrl=cfg.SQS_URL, MessageBody=json.dumps(data))
    return jsonify({"status": "queued"}), 202
