#!/bin/bash
set -e

echo "Step 3: Installing and configuring NFS Subdir External Provisioner"

# Add the Helm repository
echo "Adding the NFS Subdir External Provisioner Helm repository..."
helm repo add nfs-subdir-external-provisioner https://kubernetes-sigs.github.io/nfs-subdir-external-provisioner/
helm repo update

# Check if there are any existing releases
echo "Checking for existing NFS provisioner installations..."
if helm list -n kube-system | grep nfs-subdir-external-provisioner; then
  echo "Existing installation found, uninstalling..."
  helm uninstall nfs-subdir-external-provisioner -n kube-system
fi

# Install the NFS provisioner
echo "Installing the NFS Subdir External Provisioner..."
helm install nfs-subdir-external-provisioner nfs-subdir-external-provisioner/nfs-subdir-external-provisioner \
  --set nfs.server="$1" \
  --set nfs.path="$2" \
  --set storageClass.name=nfs-client \
  --set storageClass.defaultClass=true \
  -n kube-system

echo "Verifying the installation..."
kubectl get storageclass nfs-client
kubectl get pods -n kube-system | grep nfs-subdir-external-provisioner

echo "NFS Subdir External Provisioner installation completed."
echo "Usage example: ./03-install-nfs-provisioner.sh 192.168.1.100 /exported/path"
