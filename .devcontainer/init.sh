set -euo pipefail

echo "[init] instalando utilidades…"
sudo apt-get update -y && sudo apt-get install -y jq make

echo "[init] iniciando Docker (DinD)…"
sudo service docker start

echo "[init] creando clúster k3d (si no existe)…"
if ! k3d cluster list | grep -q plataformas2; then
  k3d cluster create plataformas2 \
    --servers 1 --agents 2 \
    --port "80:80@loadbalancer" \
    --port "443:443@loadbalancer"
fi

echo "[init] esperando CoreDNS…"
kubectl wait --for=condition=Available -n kube-system deploy/coredns --timeout=120s || true

echo "[init] agregando repos Helm…"
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

echo "[init] instalando ingress-nginx…"
helm upgrade --install ingress-nginx ingress-nginx/ingress-nginx \
  -n ingress-nginx --create-namespace

echo "[init] instalando kube-prometheus-stack (Prometheus+Grafana)…"
helm upgrade --install monitoring prometheus-community/kube-prometheus-stack \
  -n monitoring --create-namespace

echo "[init] namespaces base…"
kubectl create namespace app --dry-run=client -o yaml | kubectl apply -f -

echo "[init] todo listo: k3d + Ingress + Monitoring"
