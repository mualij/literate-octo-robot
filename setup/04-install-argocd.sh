#!/bin/bash
set -e

echo "Step 4: Installing and configuring ArgoCD"

# Create ArgoCD namespace
echo "Creating ArgoCD namespace..."
kubectl create namespace argocd

# Install ArgoCD
echo "Installing ArgoCD..."
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Wait for ArgoCD pods to be ready
echo "Waiting for ArgoCD pods to be ready..."
kubectl wait --for=condition=Available deployment/argocd-server -n argocd --timeout=300s

# Install ArgoCD CLI
echo "Installing ArgoCD CLI..."
if command -v argocd &> /dev/null; then
  echo "ArgoCD CLI is already installed."
else
  echo "Installing ArgoCD CLI..."
  sudo curl -sSL -o /usr/local/bin/argocd https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
  sudo chmod +x /usr/local/bin/argocd
fi

# Get the admin password
echo "Retrieving the initial admin password..."
ARGOCD_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
echo "ArgoCD initial admin password: $ARGOCD_PASSWORD"

# Set up port forwarding to access ArgoCD UI
echo "Setting up port forwarding for ArgoCD UI..."
echo "Run the following command in a separate terminal:"
echo "kubectl port-forward svc/argocd-server -n argocd 8080:443"

# Login to ArgoCD
echo "After port forwarding is set up, login with the following command:"
echo "argocd login localhost:8080 --username admin --password $ARGOCD_PASSWORD --insecure"

echo "ArgoCD installation and configuration completed."
