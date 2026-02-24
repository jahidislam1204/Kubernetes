#!/bin/bash

set -e

echo " Updating System"

sudo apt update -y
sudo apt upgrade -y


echo " Installing Docker"

sudo apt install -y docker.io curl apt-transport-https ca-certificates

sudo systemctl enable docker
sudo systemctl start docker

sudo usermod -aG docker $USER

echo "Docker Installed"


echo " Installing kubectl"

curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

chmod +x kubectl
sudo mv kubectl /usr/local/bin/

kubectl version --client

echo "kubectl Installed "


echo " Installing KIND"


curl -Lo ./kind https://kind.sigs.k8s.io/dl/latest/kind-linux-amd64

chmod +x kind
sudo mv kind /usr/local/bin/

kind version

echo "KIND Installed "

echo " Creating KIND Config"


cat <<EOF > kind-config.yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4

nodes:
- role: control-plane
- role: worker
- role: worker
EOF


echo " Creating Kubernetes Cluster"


kind create cluster --name dev-cluster --config kind-config.yaml


echo " Cluster Nodes"


kubectl get nodes


echo " Installing NGINX Ingress"


kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml

echo "Waiting for ingress controller..."
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=180s


echo "complete installation "
echo "run the below command after complete installation"
echo "newgrp docker"
