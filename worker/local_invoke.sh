#!/usr/bin/env bash
export AWS_ENDPOINT_URL=http://localhost:4566
export SQS_QUEUE_URL=http://localhost:4566/000000000000/orders-queue
aws --endpoint-url=$AWS_ENDPOINT_URL sqs send-message --queue-url $SQS_QUEUE_URL --message-body '{"id":"123","item":"test"}'
python -c 'import handler; print(handler.handler({"Records":[{"body":"{\\"id\\":\\"123\\",\\"item\\":\\"test\\"}"}]}, None))'
