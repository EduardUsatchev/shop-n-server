# Shop-n-Serve CI/CD Lab

## 1. Prerequisites
- AWS account via AWS Educate or standard.
- Install AWS CLI, Docker, LocalStack, Terraform, kubectl, Helm, Poetry.

## 2. Environment Setup
1. SSH keys: \`ssh-keygen -t rsa -b 4096 -f ~/.ssh/shopnserve_key\`
2. Docker Hub: create private repo shopnserve/<username>, set DOCKERHUB_TOKEN.
3. LocalStack: \`pip install localstack && localstack start -d\`

## 3. Folder Overview
| Folder      | Description                    |
|-------------|--------------------------------|
| api/        | Flask API service              |
| worker/     | Lambda worker code             |
| infra/      | Terraform configs & modules    |
| charts/     | Helm charts                    |
| .github/    | CI/CD workflows                |

## 4. Step-by-Step
```bash
cd infra/terraform
terraform init && terraform apply -auto-approve
docker build -t shopnserve/api:latest api/
helm upgrade --install api charts/api
curl http://shopnserve.nip.io/health

