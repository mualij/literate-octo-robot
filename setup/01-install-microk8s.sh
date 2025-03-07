#!/bin/bash
set -e

echo "Step 1: Installing and configuring MicroK8s"

# Install MicroK8s
echo "Installing MicroK8s..."
sudo snap install microk8s --classic --channel=1.28/stable

# Add current user to microk8s group
echo "Adding user to microk8s group..."
sudo usermod -a -G microk8s $USER
sudo chown -f -R $USER ~/.kube

# Create .kube directory if it doesn't exist
mkdir -p ~/.kube

# Generate and copy the kube config to the user's home directory
echo "Setting up kubeconfig..."
sudo microk8s config > ~/.kube/config
chmod 600 ~/.kube/config

# Enable necessary addons
echo "Enabling necessary MicroK8s addons..."
sudo microk8s enable dns storage ingress metallb helm3 host-access

echo "Waiting for MicroK8s to be ready..."
sudo microk8s status --wait-ready

echo "MicroK8s installation and configuration completed."
echo "You may need to log out and log back in for group changes to take effect."
