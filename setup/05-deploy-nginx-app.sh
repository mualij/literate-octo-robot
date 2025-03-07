#!/bin/bash
set -e

echo "Step 5: Deploying NGINX application with ArgoCD"

# Ensure ArgoCD is running
echo "Checking if ArgoCD is running..."
if ! kubectl get pods -n argocd | grep -q "argocd-server"; then
  echo "ArgoCD is not running. Please install ArgoCD first."
  exit 1
fi

# Create the argocd-test namespace
echo "Creating the argocd-test namespace..."
kubectl create namespace argocd-test --dry-run=client -o yaml | kubectl apply -f -

# Apply the ArgoCD application
echo "Applying the ArgoCD application manifest..."
kubectl apply -f nginx-app.yaml

# Check the application status
echo "Checking the application status..."
kubectl get application -n argocd

# Check if argocd CLI is installed
if command -v argocd &> /dev/null; then
  # Get the ArgoCD admin password
  echo "Getting the ArgoCD admin password..."
  ARGOCD_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
  
  echo "You'll need to login to ArgoCD to check the application status."
  echo "Run the following commands (after setting up port forwarding):"
  echo "argocd login localhost:8080 --username admin --password $ARGOCD_PASSWORD --insecure"
  echo "argocd app get nginx-app"
fi

echo "Waiting for pods to be ready in the argocd-test namespace..."
echo "This may take a minute or two for ArgoCD to sync and deploy..."
sleep 30

# Check if the pods are running
echo "Checking if the NGINX pods are running..."
kubectl get pods -n argocd-test

echo "To test the application, run the following command:"
echo "kubectl port-forward svc/nginx-service -n argocd-test 8082:80"
echo "Then visit http://localhost:8082 in your browser"

echo "NGINX application deployment completed."
