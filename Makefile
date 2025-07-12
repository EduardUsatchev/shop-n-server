.PHONY: all destroy
all: help

destroy:
	@echo "Destroying infra..."
	cd infra/terraform && terraform destroy -auto-approve
	@echo "Removing Docker images..."
	docker image prune -f
	@echo "Resetting LocalStack & k3s..."
	kill \$(lsof -t -i:4566) || true
	k3d cluster delete shopnserve || true
