K8S_DIR := k8s
GEN_DIR := $(K8S_DIR)/generated

CLICKHOUSE_VERSION ?= 24.8
ADMIN_USER        ?= admin
ADMIN_PASSWORD    ?= admin_password
READONLY_USER     ?= readonly
READONLY_PASSWORD ?= readonly_password

generate:
	mkdir -p $(GEN_DIR)

	CLICKHOUSE_VERSION=$(CLICKHOUSE_VERSION) \
	envsubst < $(K8S_DIR)/statefulset.yaml.tpl > $(GEN_DIR)/statefulset.yaml

	ADMIN_USER=$(ADMIN_USER) ADMIN_PASSWORD=$(ADMIN_PASSWORD) \
	READONLY_USER=$(READONLY_USER) READONLY_PASSWORD=$(READONLY_PASSWORD) \
	envsubst < $(K8S_DIR)/configmap-users.yaml.tpl > $(GEN_DIR)/configmap-users.yaml

	ADMIN_USER=$(ADMIN_USER) ADMIN_PASSWORD=$(ADMIN_PASSWORD) \
	READONLY_USER=$(READONLY_USER) READONLY_PASSWORD=$(READONLY_PASSWORD) \
	envsubst < $(K8S_DIR)/secret-users.yaml.tpl > $(GEN_DIR)/secret-users.yaml

apply: generate
	kubectl apply -f $(K8S_DIR)/namespace.yaml
	kubectl apply -f $(GEN_DIR)/secret-users.yaml
	kubectl apply -f $(GEN_DIR)/configmap-users.yaml
	kubectl apply -f $(GEN_DIR)/statefulset.yaml
	kubectl apply -f $(K8S_DIR)/service.yaml

delete:
	-kubectl delete -f $(K8S_DIR)/service.yaml --ignore-not-found
	-kubectl delete -f $(GEN_DIR)/statefulset.yaml --ignore-not-found
	-kubectl delete -f $(GEN_DIR)/configmap-users.yaml --ignore-not-found
	-kubectl delete -f $(GEN_DIR)/secret-users.yaml --ignore-not-found
	-kubectl delete -f $(K8S_DIR)/namespace.yaml --ignore-not-found

status:
	kubectl get pods -n clickhouse
	kubectl get svc -n clickhouse

test:
	POD=$$(kubectl get pods -n clickhouse -l app=clickhouse -o jsonpath='{.items[0].metadata.name}'); \
	kubectl exec -n clickhouse $$POD -- clickhouse-client --query="SELECT 1"

.PHONY: generate apply delete status test