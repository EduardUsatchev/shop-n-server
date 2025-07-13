#!/usr/bin/env bash
set -e

# Colors for nice output
GREEN='\033[0;32m'
NC='\033[0m' # No Color

MYSQL_CONTAINER=mysql-local
MYSQL_PORT=3306
MYSQL_ROOT_PASS=secret
MYSQL_DATABASE=shopnserve

echo -e "${GREEN}==> 1. Starting local MySQL (if not running)...${NC}"
if ! docker ps | grep -q $MYSQL_CONTAINER; then
    docker run --rm -d \
        --name $MYSQL_CONTAINER \
        -e MYSQL_ROOT_PASSWORD=$MYSQL_ROOT_PASS \
        -e MYSQL_DATABASE=$MYSQL_DATABASE \
        -p $MYSQL_PORT:3306 \
        mysql:8
    echo "Waiting for MySQL to be ready..."
    sleep 15
else
    echo "MySQL already running."
fi

echo -e "${GREEN}==> 2. Starting LocalStack (if not running)...${NC}"
if ! docker ps | grep -q localstack; then
    docker-compose -f localstack/docker-compose.yml up -d
    sleep 5
else
    echo "LocalStack already running."
fi

echo -e "${GREEN}==> 3. Provisioning SQS (skipping RDS) with Terraform...${NC}"
cd infra/terraform
terraform init
terraform apply -auto-approve -target=module.sqs
cd ../../

echo -e "${GREEN}==> 4. Building API and Worker Docker images...${NC}"
docker build -t shop-n-serve-api ./api
docker build -t shop-n-serve-worker ./worker

echo -e "${GREEN}==> 5. Running API and Worker containers...${NC}"
docker run --rm -d --name shop-n-serve-api \
    --env-file ./api/.env \
    -p 5000:5000 \
    shop-n-serve-api

docker run --rm -d --name shop-n-serve-worker \
    --env-file ./worker/.env \
    shop-n-serve-worker

sleep 5

echo -e "${GREEN}==> 6. Sending a test order to the API...${NC}"
curl -X POST -H "Content-Type: application/json" \
    -d '{"id": "order123", "item": "testitem", "qty": 1}' \
    http://localhost:5000/orders

echo -e "${GREEN}==> 7. Show orders in MySQL...${NC}"
docker exec -i $MYSQL_CONTAINER mysql -uroot -p$MYSQL_ROOT_PASS $MYSQL_DATABASE -e "SELECT * FROM orders;"

echo -e "${GREEN}==> 8. (Optional) Start Prometheus & Grafana...${NC}"
# Uncomment if you have docker-compose files for these
# docker-compose -f monitoring/docker-compose.yml up -d

echo -e "${GREEN}==> DONE. Local E2E environment is ready!${NC}"
echo "To stop everything: docker stop $MYSQL_CONTAINER shop-n-serve-api shop-n-serve-worker localstack_main"
