KIND_CLUSTER_NAME = microapp

.PHONY: kind-up
kind-up:
	kind create cluster --name $(KIND_CLUSTER_NAME) --config infra/k8s/base/kind-config.yaml

.PHONY: kind-down
kind-down:
	kind delete cluster --name $(KIND_CLUSTER_NAME)

.PHONY: kctx
kctx:
	kubectl cluster-info --context kind-$(KIND_CLUSTER_NAME)

.PHONY: restart
restart:
	make kind-down || true
	make kind-up
