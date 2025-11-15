#!/usr/bin/env bash
set -euo pipefail

apt-get update
apt-get install -y curl ca-certificates apt-transport-https gnupg lsb-release

# kubectl (estable)
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.31/deb/Release.key | gpg --dearmor -o /usr/share/keyrings/kubernetes-apt-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.31/deb/ /" >/etc/apt/sources.list.d/kubernetes.list
apt-get update && apt-get install -y kubectl

# helm
curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# k3d
curl -fsSL https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash

# Crear clúster si no existe
if ! kubectl config get-contexts 2>/dev/null | grep -q 'k3d-app'; then
  k3d cluster create app \
    --servers 1 --agents 2 \
    -p "8080:80@loadbalancer" \
    -p "8443:443@loadbalancer"
  kubectl config use-context k3d-app
fi

echo "✅ kubectl: $(kubectl version --client=true --output=json | jq -r '.clientVersion.gitVersion' 2>/dev/null || echo ok)"
echo "✅ helm: $(helm version --short 2>/dev/null || echo ok)"
echo "✅ k3d: $(k3d version 2>/dev/null || echo ok)"
kubectl get nodes -o wide || true
