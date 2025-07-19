#!/bin/bash
set -euo pipefail

# ---- Config ----
API_NAME=shopnserve-api
WORKER_NAME=shopnserve-worker
API_PORT=5000
LOCALSTACK_HELM_NAME=localstack

# ---- 1. Build Images for Minikube Docker ----
echo ">>> Setting up Docker env for Minikube..."
eval $(minikube docker-env)

echo ">>> Building API image..."
docker build -t $API_NAME:local ./api

echo ">>> Building Worker image..."
docker build -t $WORKER_NAME:local ./worker

# ---- 2. Start Minikube ----
echo ">>> Starting Minikube..."
minikube start

# ---- 3. Deploy LocalStack (Helm) ----
echo ">>> Installing LocalStack (Helm) with values.yaml ..."
helm repo add localstack-charts https://localstack.github.io/helm-charts || true
helm repo update

cat <<EOF > localstack-values.yaml
startServices: "s3,sqs,rds,iam,ec2"
service:
  type: NodePort
EOF

helm uninstall $LOCALSTACK_HELM_NAME || true

helm install $LOCALSTACK_HELM_NAME localstack-charts/localstack \
  -f localstack-values.yaml --wait

# ---- 4. Deploy API and Worker (Helm) ----
echo ">>> Installing API and Worker (Helm)..."
helm upgrade --install shopnserve-api ./charts/api \
  --set image.repository=shopnserve-api \
  --set image.tag=local \
  --set env.AWS_REGION=us-east-1 \
  --set env.AWS_ACCESS_KEY_ID=test \
  --set env.AWS_SECRET_ACCESS_KEY=test \
  --set env.SQS_QUEUE_URL=http://localstack:4566/000000000000/orders-queue \
  --set env.SQS_URL=http://localstack:4566/000000000000/orders-queue \
  --set env.DB_HOST=localhost \
  --set env.DB_USER=localuser \
  --set env.DB_PASS=localpass


if [ -d "./charts/worker" ]; then
  helm upgrade --install $WORKER_NAME ./charts/worker \
    --set image.repository=$WORKER_NAME \
    --set image.tag=local \
    --set env.AWS_REGION=us-east-1 \
    --set env.DB_HOST=localhost \
    --set env.DB_USER=localuser \
    --set env.DB_PASS=localpass
fi

# ---- 5. Wait for Deployments to be Ready ----
echo ">>> Waiting for API and Worker deployments to be ready..."
kubectl wait --for=condition=available deployment/$API_NAME --timeout=120s
if kubectl get deployment/$WORKER_NAME >/dev/null 2>&1; then
  kubectl wait --for=condition=available deployment/$WORKER_NAME --timeout=120s
fi

# ---- 6. Wait for Service and Port-forward API ----
echo ">>> Waiting for $API_NAME service to be created..."
for i in {1..30}; do
  if kubectl get svc $API_NAME >/dev/null 2>&1; then
    echo "Service $API_NAME found."
    break
  fi
  echo "Waiting for service $API_NAME (try $i/30)..."
  sleep 2
done

if ! kubectl get svc $API_NAME >/dev/null 2>&1; then
  echo ">>> ❌ ERROR: Service $API_NAME not found. Check your Helm chart!"
  exit 1
fi

echo ">>> Port-forwarding API service to localhost:$API_PORT ..."
kubectl port-forward svc/$API_NAME $API_PORT:$API_PORT &
PF_PID=$!
sleep 5  # Wait for port-forward

# ---- 7. Check API Endpoints ----
function check_api() {
  local url="$1"
  echo -n "Checking $url ... "
  http_status=$(curl -s -o /dev/null -w "%{http_code}" "$url")
  if [[ "$http_status" == "200" ]]; then
    echo "OK"
  else
    echo "FAILED (HTTP $http_status)"
    return 1
  fi
}

RESULT=0

check_api "http://localhost:$API_PORT/health" || RESULT=1
check_api "http://localhost:$API_PORT/metrics" || RESULT=1

# Optional: Post a sample order, if such an endpoint exists
if curl -s -o /dev/null -w "%{http_code}" -X POST "http://localhost:$API_PORT/orders" \
  -H "Content-Type: application/json" \
  -d '{"id": "testorder", "item": "coffee"}' | grep -E '200|201|202' > /dev/null; then
  echo "POST /orders ... OK"
else
  echo "POST /orders ... SKIP or FAILED"
fi

# ---- 8. Cleanup Port-Forward ----
kill $PF_PID 2>/dev/null || true

# ---- 9. Summary ----
if [ "$RESULT" -eq 0 ]; then
  echo ">>> ✅ ALL CHECKS PASSED. The lab is running correctly in Minikube!"
else
  echo ">>> ❌ Some checks FAILED. Check logs and troubleshoot."
  exit 1
fi
