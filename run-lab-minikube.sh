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

# ---- 3. Deploy LocalStack ----
echo ">>> Installing LocalStack (Helm)..."
helm repo add localstack-charts https://localstack.github.io/helm-charts
helm repo update
helm install $LOCALSTACK_HELM_NAME localstack-charts/localstack \
  --set startServices="s3,sqs,rds,iam,ec2" \
  --set service.type=NodePort --wait

# ---- 4. Deploy API and Worker (Helm) ----
echo ">>> Installing API and Worker (Helm)..."
# Replace values as needed for your chart structure
helm upgrade --install $API_NAME ./charts/api \
  --set image.repository=$API_NAME \
  --set image.tag=local \
  --set env.AWS_REGION=us-east-1 \
  --set env.DB_HOST=localhost \
  --set env.DB_USER=localuser \
  --set env.DB_PASS=localpass

# Optional: If you have a dedicated chart for worker
if [ -d "./charts/worker" ]; then
  helm upgrade --install $WORKER_NAME ./charts/worker \
    --set image.repository=$WORKER_NAME \
    --set image.tag=local \
    --set env.AWS_REGION=us-east-1 \
    --set env.DB_HOST=localhost \
    --set env.DB_USER=localuser \
    --set env.DB_PASS=localpass
fi

# ---- 5. Wait for Pods to be Ready ----
echo ">>> Waiting for API and Worker pods to be ready..."
kubectl wait --for=condition=available deployment/$API_NAME --timeout=120s
if kubectl get deployment/$WORKER_NAME >/dev/null 2>&1; then
  kubectl wait --for=condition=available deployment/$WORKER_NAME --timeout=120s
fi

# ---- 6. Port-forward API ----
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
  -d '{"id": "testorder", "item": "coffee"}' | grep -q 200; then
  echo "POST /orders ... OK"
else
  echo "POST /orders ... SKIP or FAILED"
fi

# ---- 8. Cleanup Port-Forward ----
kill $PF_PID

# ---- 9. Summary ----
if [ "$RESULT" -eq 0 ]; then
  echo ">>> ✅ ALL CHECKS PASSED. The lab is running correctly in Minikube!"
else
  echo ">>> ❌ Some checks FAILED. Check logs and troubleshoot."
  exit 1
fi
