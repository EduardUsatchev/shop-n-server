import os
import json
import boto3
import pymysql

class DBClient:
    def __init__(self, host, user, password):
        self.conn = pymysql.connect(host=host, user=user, password=password, db="shopnserve")

    def write_order(self, order):
        with self.conn.cursor() as cur:
            cur.execute(
                "INSERT INTO orders (id, payload) VALUES (%s, %s)",
                (order["id"], json.dumps(order))
            )
        self.conn.commit()

def handler(event, context, db_client=None):
    db = db_client or DBClient(
        os.getenv("DB_HOST"),
        os.getenv("DB_USER"),
        os.getenv("DB_PASS")
    )
    # If you ever use boto3, **always** pass region_name from env:
    # sqs = boto3.client(
    #     "sqs",
    #     region_name=os.getenv("AWS_REGION"),
    #     endpoint_url=os.getenv("AWS_ENDPOINT_URL")  # Optional, for localstack
    # )
    for record in event['Records']:
        order = json.loads(record['body'])
        db.write_order(order)
    return {"statusCode": 200}
