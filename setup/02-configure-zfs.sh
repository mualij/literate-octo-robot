#!/bin/bash
set -e

echo "Step 2: Creating and configuring ZFS for Kubernetes"

# Create ZFS dataset for Kubernetes
echo "Creating ZFS dataset for Kubernetes..."
sudo zfs create datapool/kubernetes

# Set mount point
sudo zfs set mountpoint=/var/lib/kubernetes datapool/kubernetes

# Stop MicroK8s to modify containerd config
echo "Stopping MicroK8s to modify containerd config..."
sudo microk8s stop

# Install required packages for ZFS snapshotter
echo "Installing required packages for ZFS snapshotter..."
sudo apt update
sudo apt install -y zfsutils-linux containerd

# Configure containerd to use ZFS snapshotter
echo "Configuring containerd to use ZFS snapshotter..."
sudo mkdir -p /etc/containerd
cat << EOT | sudo tee /etc/containerd/config.toml
version = 2

[plugins]
  [plugins."io.containerd.grpc.v1.cri"]
    [plugins."io.containerd.grpc.v1.cri".containerd]
      snapshotter = "zfs"
      default_runtime_name = "runc"
      [plugins."io.containerd.grpc.v1.cri".containerd.runtimes]
        [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc]
          runtime_type = "io.containerd.runc.v2"
EOT

# Restart MicroK8s to apply changes
echo "Restarting MicroK8s to apply changes..."
sudo microk8s start

# Wait for MicroK8s to be ready
echo "Waiting for MicroK8s to be ready..."
sudo microk8s status --wait-ready

echo "ZFS configuration for Kubernetes completed."
